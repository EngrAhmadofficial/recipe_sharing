require 'faker'

puts "Seeding recipes with matching images for Asian dishes..."

Recipe.destroy_all
# Function to generate instructions as bullet points
def generate_instructions
  steps = [
    "Prepare the ingredients: wash, chop, and measure as needed.",
    "Heat oil in a pan or wok over medium heat.",
    "Cook the primary ingredients (e.g., protein or vegetables) until partially done.",
    "Add sauces and spices as required, stirring well.",
    "Let the dish simmer until fully cooked and flavors blend.",
    "Plate the dish and garnish as desired."
  ]
  steps.sample(5) # Select 5 random steps
end

# Seeding 10 recipes for Asian dishes
10.times do
  # Generate an Asian dish name using Faker
  food_name = Faker::Food.dish

  # Fetch an image from Unsplash using the food name
  begin
    photo = Unsplash::Photo.random(query: "#{food_name} Asian")
    image_url = photo.urls["regular"]
  rescue StandardError => e
    puts "Error fetching Unsplash image for #{food_name}: #{e.message}"
    image_url = "https://via.placeholder.com/600x400?text=#{URI.encode(food_name)}" # Fallback to a placeholder image
  end

  # Generate random ingredients (specific to Asian cuisine)
  ingredients = Array.new(5) { Faker::Food.ingredient }.join(", ")

  # Create a recipe record
  Recipe.create!(
    name: food_name,
    ingredients: ingredients,
    instructions: generate_instructions.join("\n- "), # Format as bullet points
    image_url: image_url,
    slug: food_name.parameterize
  )

  puts "Created recipe: #{Recipe.last.name} with image."
end

puts "Seeding completed!"
