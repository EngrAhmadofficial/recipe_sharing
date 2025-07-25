require 'http'

class AiRecipeService
  API_URL = "https://api.openai.com/v1/chat/completions".freeze
  API_KEY = ENV['OPENAI_API_KEY']

  class << self
    # 1. AI-based Personalized Recipe Recommendations
    def get_personalized_recommendations(user, query = nil)
      prompt = build_personalization_prompt(user, query)
      response = make_request(prompt, "personalized_recommendations")
      parse_response(response)
    end

    # 2. Ingredient-Based Recipe Search
    def find_recipes_by_ingredients(ingredients, user = nil)
      prompt = build_ingredient_search_prompt(ingredients, user)
      response = make_request(prompt, "ingredient_search")
      parse_response(response)
    end

    # 3. Nutritional Analysis
    def analyze_nutrition(recipe_data)
      prompt = build_nutrition_analysis_prompt(recipe_data)
      response = make_request(prompt, "nutrition_analysis")
      parse_response(response)
    end

    # 4. Meal Planning
    def generate_meal_plan(user, days = 7, preferences = {})
      Rails.logger.info("Building meal planning prompt for #{days} days")
      prompt = build_meal_planning_prompt(user, days, preferences)
      Rails.logger.info("Making AI request...")
      response = make_request(prompt, "meal_planning")
      Rails.logger.info("Parsing AI response...")
      result = parse_response(response)
      Rails.logger.info("Meal plan result: #{result.class}")
      result
    end

    # 5. Grocery List Generation
    def generate_grocery_list(recipes, user = nil)
      prompt = build_grocery_list_prompt(recipes, user)
      response = make_request(prompt, "grocery_list")
      parse_response(response)
    end

    # 5b. Grocery List Generation from Ingredients
    def generate_grocery_list_from_ingredients(ingredients, user = nil)
      prompt = build_grocery_list_from_ingredients_prompt(ingredients, user)
      response = make_request(prompt, "grocery_list")
      parse_response(response)
    end

    # 6. Diet Advice and Health Tips
    def get_diet_advice(user, goal)
      prompt = build_diet_advice_prompt(user, goal)
      response = make_request(prompt, "diet_advice")
      parse_response(response)
    end

    # 7. Recipe Modification for Dietary Restrictions
    def modify_recipe_for_diet(recipe, user)
      prompt = build_recipe_modification_prompt(recipe, user)
      response = make_request(prompt, "recipe_modification")
      parse_response(response)
    end

    private

    def build_personalization_prompt(user, query)
      user_preferences = extract_user_preferences(user)
      
      <<~PROMPT
        You are an AI nutritionist and recipe expert. Based on the following user profile, provide personalized recipe recommendations.

        User Profile:
        - Diet Goals: #{user_preferences[:diet_goals]}
        - Allergies: #{user_preferences[:allergies]}
        - Cooking Skill: #{user_preferences[:cooking_skill]}
        - Health Conditions: #{user_preferences[:health_conditions]}
 Preferences: #{user_preferences[:meal_preferences]}
        - Favorite Categories: #{user_preferences[:favorite_categories]}

        User Query: #{query || "Recommend healthy recipes"}

        Please provide:
        1. 3-5 personalized recipe recommendations with detailed nutritional information
        2. Explanation of why each recipe fits their profile
        3. Cooking tips based on their skill level
        4. Substitution suggestions for any allergies

        Return the response in JSON format with the following structure:
        {
          "recommendations": [
            {
              "name": "Recipe Name",
              "calories": 300,
              "protein": 25,
              "carbs": 30,
              "fats": 12,
              "ingredients": [...],
              "instructions": [...],
              "why_recommended": "Explanation",
              "cooking_tips": "Tips for their skill level",
              "substitutions": "Allergy-friendly alternatives"
            }
          ],
          "summary": "Overall recommendation summary"
        }
      PROMPT
    end

    def build_ingredient_search_prompt(ingredients, user)
      user_preferences = user ? extract_user_preferences(user) : {}
      
      <<~PROMPT
        You are a recipe finder. The user has these ingredients: #{ingredients.join(', ')}.

        User Preferences: #{user_preferences.empty? ? 'None specified' : user_preferences.to_json}

        Please provide:
        1. Recipes that use most/all of these ingredients
        2. Recipes that use some of these ingredients (with missing ingredients listed)
        3. Creative ways to use these ingredients
        4. Shopping suggestions for additional ingredients

        Return in JSON format:
        {
          "exact_matches": [...],
          "partial_matches": [...],
          "creative_uses": [...],
          "shopping_suggestions": [...]
        }
      PROMPT
    end

    def build_nutrition_analysis_prompt(recipe_data)
      <<~PROMPT
        Analyze the nutritional content of this recipe:

        Recipe: #{recipe_data}

        Please provide:
        1. Detailed nutritional breakdown (calories, macros, vitamins, minerals)
        2. Health benefits
        3. Potential concerns
        4. Suggestions for improvement
        5. Dietary classification (vegan, keto, etc.)

        Return in JSON format with nutritional analysis.
      PROMPT
    end

    def build_meal_planning_prompt(user, days, preferences)
      user_preferences = extract_user_preferences(user)
      
      <<~PROMPT
        Create a #{days}-day meal plan for this user:

        User Profile: #{user_preferences.to_json}
        Additional Preferences: #{preferences.to_json}

        Requirements:
        1. Balanced nutrition across the week
        2. Variety in meals
        3. Consider cooking time and skill level
        4. Account for dietary restrictions
        5. Include snacks if needed

        Return ONLY valid JSON in this exact format (keep instructions brief):
        {
          "meal_plan": [
            {
              "day": "Monday",
              "meals": {
                "breakfast": {
                  "name": "Recipe Name",
                  "calories": 300,
                  "protein": 15,
                  "carbs": 30,
                  "fats": 10,
                  "ingredients": ["ingredient1", "ingredient2"],
                  "instructions": "Brief cooking steps"
                },
                "lunch": {
                  "name": "Recipe Name",
                  "calories": 500,
                  "protein": 25,
                  "carbs": 60,
                  "fats": 15,
                  "ingredients": ["ingredient1", "ingredient2"],
                  "instructions": "Brief cooking steps"
                },
                "dinner": {
                  "name": "Recipe Name",
                  "calories": 600,
                  "protein": 30,
                  "carbs": 70,
                  "fats": 20,
                  "ingredients": ["ingredient1", "ingredient2"],
                  "instructions": "Brief cooking steps"
                },
                "snacks": [
                  {
                    "name": "Snack Name",
                    "calories": 150,
                    "protein": 5,
                    "carbs": 20,
                    "fats": 5,
                    "ingredients": ["ingredient1"],
                    "instructions": "Brief preparation"
                  }
                ]
              },
              "daily_totals": {
                "calories": 1550,
                "protein": 75,
                "carbs": 180,
                "fats": 50
              }
            }
          ],
          "summary": "Weekly meal plan summary"
        }

        IMPORTANT: Keep instructions very brief (1-2 sentences max) to avoid truncation.
      PROMPT
    end

    def build_grocery_list_prompt(recipes, user)
      user_preferences = user ? extract_user_preferences(user) : {}
      
      <<~PROMPT
        Generate a grocery list for these recipes: #{recipes.map(&:name).join(', ')}

        User Preferences: #{user_preferences.to_json}

        Please provide a simple JSON structure like this:
        {
          "grocery_list": {
            "categories": {
              "Fruits": ["apples", "bananas", "oranges"],
              "Vegetables": ["carrots", "broccoli", "spinach"],
              "Proteins": ["chicken breast", "eggs", "tofu"],
              "Grains": ["brown rice", "whole wheat bread"],
              "Dairy": ["milk", "yogurt", "cheese"],
              "Condiments": ["olive oil", "soy sauce", "salt"]
            },
            "notes": [
              "Buy organic when possible",
              "Check for sales on bulk items",
              "Store perishables properly"
            ]
          }
        }

        Keep it simple and organized by category. Do not include markdown formatting.
      PROMPT
    end

    def build_grocery_list_from_ingredients_prompt(ingredients, user)
      user_preferences = user ? extract_user_preferences(user) : {}
      <<~PROMPT
        Generate a categorized grocery list for these ingredients: #{ingredients.join(', ')}

        User Preferences: #{user_preferences.to_json}

        Please provide a simple JSON structure like this:
        {
          "grocery_list": {
            "categories": {
              "Fruits": ["apples", "bananas", "oranges"],
              "Vegetables": ["carrots", "broccoli", "spinach"],
              "Proteins": ["chicken breast", "eggs", "tofu"],
              "Grains": ["brown rice", "whole wheat bread"],
              "Dairy": ["milk", "yogurt", "cheese"],
              "Condiments": ["olive oil", "soy sauce", "salt"]
            },
            "notes": [
              "Buy organic when possible",
              "Check for sales on bulk items",
              "Store perishables properly"
            ]
          }
        }

        Keep it simple and organized by category. Do not include markdown formatting.
      PROMPT
    end

    def build_diet_advice_prompt(user, goal)
      user_preferences = extract_user_preferences(user)
      
      <<~PROMPT
        Provide personalized diet advice for this user:

        User Profile: #{user_preferences.to_json}
        Goal: #{goal}

        Please provide:
        1. Personalized diet recommendations
        2. Meal timing suggestions
        3. Foods to include/avoid
        4. Progress tracking tips
        5. Recipe suggestions

        Return in JSON format with comprehensive diet advice.
      PROMPT
    end

    def build_recipe_modification_prompt(recipe, user)
      user_preferences = extract_user_preferences(user)
      
      <<~PROMPT
        Modify this recipe for the user's dietary needs:

        Original Recipe: #{recipe.attributes.to_json}
        User Restrictions: #{user_preferences.to_json}

        Please provide:
        1. Modified recipe with substitutions
        2. Alternative ingredients
        3. Cooking method adjustments
        4. Nutritional comparison
        5. Taste preservation tips

        Return in JSON format with modified recipe.
      PROMPT
    end

    def extract_user_preferences(user)
      {
        diet_goals: user.diet_goals || [],
        allergies: user.allergies || [],
        cooking_skill: user.cooking_skill || 'beginner',
        health_conditions: user.health_conditions || [],
        meal_preferences: user.meal_preferences || {},
        favorite_categories: user.preferences&.dig('favoriteCategories') || []
      }
    end

    def make_request(prompt, service_type)
      messages = [
        { 
          role: "system", 
          content: "You are an expert nutritionist and recipe consultant. Always return data in JSON format. Be specific, helpful, and considerate of dietary restrictions and health conditions. Keep responses concise and complete." 
        },
        { role: "user", content: prompt }
      ]

      HTTP.post(API_URL, json: {
        model: "gpt-4o-mini",
        messages: messages,
        max_tokens: 3000,
        temperature: 0.7
      }, headers: {
        "Authorization" => "Bearer #{API_KEY}",
        "Content-Type" => "application/json"
      })
    end

    def parse_response(response)
      unless response.status.success?
        Rails.logger.error("AI API Error: #{response.status} - #{response.body.to_s}")
        return { error: "Unable to fetch results (HTTP #{response.status})" }
      end

      begin
        parsed_response = JSON.parse(response.body.to_s)
        content = parsed_response.dig("choices", 0, "message", "content") || "No results found."
        Rails.logger.info("AI content length: #{content.length}")
        Rails.logger.info("AI content preview: #{content[0..200]}...")
        result = parse_ai_content(content)
        Rails.logger.info("Parsed result: #{result.class}")
        result
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse AI response: #{e.message}")
        { error: "Unable to process response from AI." }
      end
    end

    def parse_ai_content(content)
      cleaned_content = content.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip
      
      begin
        JSON.parse(cleaned_content)
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse AI content as JSON: #{e.message}")
        Rails.logger.error("Raw content: #{content}")
        
        # Try to extract and fix incomplete JSON
        begin
          # For meal planning, try to extract complete days
          if content.include?('"meal_plan"')
            # Find the start of the meal_plan array
            meal_plan_start = content.index('"meal_plan"')
            if meal_plan_start
              # Find all complete day objects by looking for the pattern
              # Each day should end with "daily_totals": {...}
              day_objects = []
              remaining_content = content[meal_plan_start..-1]
              
              # Split by day objects and find complete ones
              day_splits = remaining_content.split(/\{"day":\s*"/)
              day_splits.shift # Remove the first empty split
              
              day_splits.each do |day_content|
                # Find the end of this day object
                # Look for the closing brace that matches the opening of this day
                brace_count = 0
                end_index = -1
                
                day_content.chars.each_with_index do |char, index|
                  if char == '{'
                    brace_count += 1
                  elsif char == '}'
                    brace_count -= 1
                    if brace_count == 0
                      end_index = index
                      break
                    end
                  end
                end
                
                if end_index >= 0
                  # This is a complete day object
                  complete_day = '{"day": "' + day_content[0..end_index]
                  begin
                    # Test if this day object is valid JSON
                    JSON.parse(complete_day)
                    day_objects << complete_day
                  rescue JSON::ParserError
                    # Skip this incomplete day
                  end
                end
              end
              
              if day_objects.any?
                fixed_json = "{\"meal_plan\":[#{day_objects.join(',')}],\"summary\":\"Weekly meal plan with #{day_objects.length} complete days\"}"
                return JSON.parse(fixed_json)
              end
            end
          end
          
          # Fallback: try to extract any valid JSON
          json_match = content.match(/\{.*\}/m)
          if json_match
            JSON.parse(json_match[0])
          else
            { error: "Unable to parse AI response", raw_content: content }
          end
        rescue JSON::ParserError
          { error: "Unable to parse AI response", raw_content: content }
        end
      end
    end
  end
end 