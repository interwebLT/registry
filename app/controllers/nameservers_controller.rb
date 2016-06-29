class NameserversController < SecureController
  def index
    render json: Nameserver.all
  end
end