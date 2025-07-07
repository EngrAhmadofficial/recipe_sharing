class Recipe < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :user_recipes, dependent: :destroy
  has_many :users, through: :user_recipes
  has_many :meal_plans, dependent: :destroy
  
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  # Validations
  validates :name, presence: true
  validates :ingredients, presence: true
  validates :instructions, presence: true
  validates :calories, numericality: { greater_than: 0, allow_nil: true }
  validates :protein, :carbs, :fats, :fiber, :sugar, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :sodium, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  
  # Scopes
  scope :by_category, ->(category) { where(category: category) }
  scope :low_calorie, -> { where('calories <= ?', 300) }
  scope :high_protein, -> { where('protein >= ?', 20) }
  scope :vegetarian, -> { where("ingredients ILIKE ?", '%vegetarian%') }
  scope :vegan, -> { where("ingredients ILIKE ?", '%vegan%') }
  
  # Instance methods
  def average_rating
    user_recipes.average(:rating)&.round(1) || 0
  end
  
  def total_reviews
    user_recipes.where.not(review: [nil, '']).count
  end
  
  def favorite_count
    user_recipes.where(favorite: true).count
  end
end
