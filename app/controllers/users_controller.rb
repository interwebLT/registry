class UsersController < ApplicationController
  def create 
    user = User.new user_params
    
    user.partner = Partner.find params[:partner_id]

    if user.save
      render json: user
    elsif User.exists?(email: user.email)
      render validation_failed user
    else
      render bad_request
    end
  end

  private

  def user_params
    params.permit :email, :name, :password, :username
  end
end
