class Powerdns::DomainsController < SecureController
  def index
    render json: Powerdns::Domain.all
  end
end