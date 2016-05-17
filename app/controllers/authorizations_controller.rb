class AuthorizationsController < ApplicationController
  def create
    partner = Partner.find_by name: params[:username]

    if partner.present? && partner.password_matches(params[:password])
      authorization = partner.authorizations.create

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
