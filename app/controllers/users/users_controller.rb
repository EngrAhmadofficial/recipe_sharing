class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @recipes = current_user.recipes
  end
end