class RecipeMailer < ApplicationMailer
  def new_recipe_email(user, recipe)
    @user = user
    @recipe = recipe
    mail(to: @user.email, subject: "New Recipe: #{@recipe.name}")
  end
end
