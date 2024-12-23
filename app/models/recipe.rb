class Recipe < ApplicationRecord
  has_and_belongs_to_many :products
  extend FriendlyId
  friendly_id :name, use: :slugged
end
