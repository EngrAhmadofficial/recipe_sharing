class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_secure_password
  validates :email, presence: true, uniqueness: true
  
  # Relationships
  has_many :meal_plans, dependent: :destroy
  has_many :grocery_lists, dependent: :destroy
  has_many :user_recipes, dependent: :destroy
  has_many :favorite_recipes, through: :user_recipes, source: :recipe
  
  # Validations
  validates :cooking_skill, inclusion: { in: %w[beginner intermediate advanced], allow_blank: true }
  
  # Default values for JSON fields
  after_initialize :set_defaults, if: :new_record?
  
  private
  
  def set_defaults
    self.preferences ||= {}
    self.diet_goals ||= []
    self.allergies ||= []
    self.meal_preferences ||= {}
    self.health_conditions ||= []
  end
end
