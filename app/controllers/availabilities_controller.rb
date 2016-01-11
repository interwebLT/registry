class AvailabilitiesController < ApplicationController
  def index
    result = []
    if params[:domain].nil?
      render json: {}
      return
    end

    domain = DomainSearchLog.new name: params[:domain]
    domain.save

    available_tlds = Domain.available_tlds(params[:domain])

    result << {
      domain: params[:domain],
      available_tlds: available_tlds
    }

    render json: result
  end
end
