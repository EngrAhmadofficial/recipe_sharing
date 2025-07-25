class UserRecipe < ApplicationRecord
  belongs_to :user
  belongs_to :recipe
  
  # Validations
  validates :rating, inclusion: { in: 1..5, allow_nil: true }
  validates :user_id, uniqueness: { scope: :recipe_id, message: "You've already reviewed this recipe" }
  
  # Scopes
  scope :favorites, -> { where(favorite: true) }
  scope :rated, -> { where.not(rating: nil) }
  scope :with_reviews, -> { where.not(review: [nil, '']) }
  
  # Instance methods
  def toggle_favorite!
    update(favorite: !favorite)
  end
  
  def star_rating
    return 0 if rating.nil?
    rating
  end
end
