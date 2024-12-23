require 'faker'

# Clear existing data
Product.destroy_all

# Categories for products
english_categories = [
  "Dairy Products", "Bakery Items", "Snacks", "Beverages", "Meat"
]
asian_categories = [
  "Rice", "Noodles", "Spices", "Seafood", "Asian Snacks"
]

# Helper method to generate random products
def create_products(count, region, categories)
  count.times do
    Product.create!(
      name: "#{region} Product: #{Faker::Food.ingredient}",
      description: Faker::Food.description,
      price: Faker::Commerce.price(range: 1..100),
      image_url: Faker::LoremFlickr.image(size: "300x300", search_terms: ['food']),
    )
  end
end

# Create English Products
puts "Creating English products..."
create_products(20, "English", english_categories)

# Create Asian Products
puts "Creating Asian products..."
create_products(20, "Asian", asian_categories)

# Create some sample recipes
puts "Creating sample recipes..."
10.times do
  recipe = Recipe.create!(
    name: Faker::Food.dish,
    ingredients: Faker::Food.ingredient + ", " + Faker::Food.ingredient + ", " + Faker::Food.ingredient,
    instructions: Faker::Lorem.paragraph(sentence_count: 3),
    image_url: Faker::LoremFlickr.image(size: "600x400", search_terms: ['recipe'])
  )

  # Associate products with the recipe
  recipe.products << Product.order("RANDOM()").limit(3)
end

puts "Seed data created successfully!"
