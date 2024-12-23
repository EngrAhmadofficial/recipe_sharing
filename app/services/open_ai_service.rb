require 'http'

class OpenAiService
  API_URL = "https://api.openai.com/v1/chat/completions".freeze
  API_KEY = ENV['OPENAI_API_KEY']

  class << self
    def search_recipes(query, recipes, products)
      prompt = build_prompt(query, recipes, products)
      messages = [
        { role: "system", content: "You are a recipe search assistant. and always send me data in JSON format." },
        { role: "user", content: prompt }
      ]

      response = make_request(messages)

      parse_response(response)
    end

    private

    def build_prompt(query, recipes, products)
      recipe_list = recipes.map { |r| "#{r.name}: #{r.ingredients}" }.join("\n")
      product_list = products.map { |p| "#{p.name}: #{p.description}" }.join("\n")

      <<~PROMPT
        Here is a list of recipes:
        #{recipe_list}
      
        Here is a list of available products:
        #{product_list}
      
        User query: #{query}
      
        Return the best matching recipe(s) and suggest products that the user might need.
      PROMPT
    end

    def make_request(messages)
      HTTP.post(API_URL, json: {
        model: "gpt-4o-mini",
        messages: messages,
        max_tokens: 300,
        temperature: 0.7
      }, headers: {
        "Authorization" => "Bearer #{API_KEY}",
        "Content-Type" => "application/json"
      })
    end

    def parse_response(response)
      unless response.status.success?
        log_error(response)
        return "Error: Unable to fetch results (HTTP #{response.status})"
      end
      parsed_response = JSON.parse(response.body.to_s)
      puts "#{parsed_response}"
      parsed_response.dig("choices", 0, "message", "content") || "No results found."
    rescue JSON::ParserError => e
      log_error(response, e)
      "Error: Unable to process response from AI."
    end

    def log_error(response, exception = nil)
      Rails.logger.error("OpenAI API Error: #{response.status} - #{response.body.to_s}")
      Rails.logger.error("Exception: #{exception.message}") if exception
    end
  end
end
