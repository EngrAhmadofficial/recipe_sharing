class Recipe < ApplicationRecord
  acts_as_votable
  extend FriendlyId
  friendly_id :name, use: :slugged
end
