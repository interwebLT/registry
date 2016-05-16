class SecureController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def current_partner
    partner = @authorization.partner
    partner.token = @authorization.token

    partner
  end

  private

  def authenticate
    render not_found unless authenticate_token
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @authorization = Partner.authorize token
    end
  end
end
