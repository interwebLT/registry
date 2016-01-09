class AuthorizationsController < ApplicationController
  def create
    user = User.find_by(email: params[:username])
    user ||= User.find_by(username: params[:username]) unless params[:username].blank?

    if user.present? && user.password_matches(params[:password])
      authorization = user.authorizations.create

      render json: authorization, status: :created, location: authorization
    else
      render json: { message: 'Bad Credentials' }, status: :unprocessable_entity
    end
  end

  def show
    begin
      render json: Authorization.find(params[:id])
    rescue
      render not_found
    end
  end
end
