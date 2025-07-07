class UsersController < ApplicationController
  before_action :authenticate_user!

  def update_preferences
    # Assuming `favorite_categories` is an array of strings
    current_user.update(preferences: { favoriteCategories: params[:favorite_categories] })
    redirect_to root_path, notice: "Preferences updated successfully."
  end

  def authenticate(password)
    BCrypt::Password.new(password_digest) == password
  end

end
