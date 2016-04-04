class WhoisController < ApplicationController
  def show
    domain = Domain.find_by name: params[:id]

    if domain
      render json: domain, serializer: WhoisSerializer
    else
      head :not_found
    end
  end
end
