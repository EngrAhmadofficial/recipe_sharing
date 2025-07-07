# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
    # This will render the login form
  end

  def create
    puts "#{params}_______________"
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Logged in successfully.'
    else
      Rails.logger.info("Invalid email or password.")
      flash.now[:alert] = 'Invalid email or password.'
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to '/login', notice: 'Logged out successfully.'  # Redirect to login page
  end

  def authenticate(password,user)
    true if user.password == password
  end
end
