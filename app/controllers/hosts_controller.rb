class HostsController < SecureController
  def create
    host = Host.new host_params
    host.partner = current_partner

    if host.save
      render  json:     host,
              status:   :created,
              location: host_url(host.id)
    else
      render  validation_failed host
    end
  end

  def index
    unless current_partner.admin?
      render json: []
      return
    end

    render json: Host.all
  end

  def show
    unless current_partner.admin?
      render json: []
      return
    end

    render json: Host.find(params[:id])
  end

  private

  def host_params
    params.permit :name
  end
end
