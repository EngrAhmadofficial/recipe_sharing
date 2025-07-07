require 'http'

class OpenAiService
  API_URL = "https://api.openai.com/v1/chat/completions".freeze
  API_KEY = ENV['OPENAI_API_KEY']

  class << self
    def search_recipes(query, recipes, products)
      # Build prompt based on the available recipes and products
      prompt = build_prompt(query, recipes, products)

      # Construct the message array for OpenAI API
      messages = [
        { role: "system", content: "You are a recipe search assistant. Always return data in JSON format. Include recipe details with calorie counts and ingredients." },
        { role: "user", content: prompt }
      ]

      # Make the request to OpenAI API
      response = make_request(messages)

      # Parse and return the response
      parse_response(response)
    end

    private

    def build_prompt(query, recipes, products)
      # Ensure recipes and products are not nil before trying to use them
      recipe_list = recipes.present? ? recipes.map { |r| "#{r.name}: #{r.ingredients}, Calories: #{r.calories}" }.join("\n") : "No recipes available."
      product_list = products.present? ? products.map { |p| "#{p.name}: #{p.description}" }.join("\n") : "No products available."

      <<~PROMPT
        Here is a list of recipes:
        #{recipe_list}
      
        Here is a list of available products:
        #{product_list}
      
        User query: #{query}
      
        Return the best matching recipe(s) and suggest products that the user might need. Include calories and ingredient details.
      PROMPT
    end

    def make_request(messages)
      HTTP.post(API_URL, json: {
        model: "gpt-4o-mini",
        messages: messages,
        max_tokens: 500,  # Increase token limit for detailed responses
        temperature: 0.7
      }, headers: {
        "Authorization" => "Bearer #{API_KEY}",
        "Content-Type" => "application/json"
      })
    end

    def parse_response(response)
      # Check if the response is successful
      unless response.status.success?
        log_error(response)
        return { error: "Unable to fetch results (HTTP #{response.status})" }
      end

      # Parse the JSON response from OpenAI
      begin
        parsed_response = JSON.parse(response.body.to_s)
        puts "#{parsed_response}"  # Debugging output

        # Extract the content of the response (recipe data)
        content = parsed_response.dig("choices", 0, "message", "content") || "No results found."
        
        # Try to parse the content as JSON (it might be wrapped in markdown code blocks)
        parse_ai_content(content)
      rescue JSON::ParserError => e
        log_error(response, e)
        { error: "Unable to process response from AI." }
      end
    end

    def parse_ai_content(content)
      # Remove markdown code blocks if present
      cleaned_content = content.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
      
      begin
        JSON.parse(cleaned_content)
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse AI content as JSON: #{e.message}")
        Rails.logger.error("Content: #{cleaned_content}")
        { error: "Unable to parse AI response", raw_content: content }
      end
    end

    def log_error(response, exception = nil)
      # Log any errors from the OpenAI API
      Rails.logger.error("OpenAI API Error: #{response.status} - #{response.body.to_s}")
      Rails.logger.error("Exception: #{exception.message}") if exception
    end
  end
end
