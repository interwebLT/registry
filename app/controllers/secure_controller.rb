class SecureController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def current_partner
    partner = @authorization.partner
    partner.token   = @authorization.token
    partner.client  = @authorization.client

    partner
  end

  def current_user
    current_partner
  end

  def headers
    {
      'Content-Type'  => 'application/json',
      'Accept'        => 'application/json',
      'Authorization' => "Token token=#{current_partner.token}"
    }
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
