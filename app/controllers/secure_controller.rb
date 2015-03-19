class SecureController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def current_user
    user = @authorization.user
    user.token = @authorization.token

    user
  end

  private

  def authenticate
    render not_found unless authenticate_token
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @authorization = User.authorize! token
    end
  end
end
