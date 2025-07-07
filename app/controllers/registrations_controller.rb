class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    Rails.logger.info "User params: #{user_params}"
    Rails.logger.info "User valid? #{@user.valid?}"
    Rails.logger.info "User errors: #{@user.errors.full_messages}" unless @user.valid?

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Sign up successful.'
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
