class HostsController < SecureController
  REQUIRED_PARAMS = [:name]

  def create
    if create_valid?
      create_host
    else
      render missing_fields missing_params
    end
  end

  def index
    unless current_user.admin?
      render json: []
      return
    end

    render json: Host.all
  end

  def show
    unless current_user.admin?
      render json: []
      return
    end

    render json: Host.find(params[:id])
  end

  private

  def host_params
    params.permit(:partner, :name)
  end

  def host_partner
    Partner.find_by(name: host_params[:partner], admin: false)
  end

  def missing_params
    missing_params = REQUIRED_PARAMS.reject { |key| host_params.include? key }
    missing_params << :partner if missing_admin_params

    missing_params
  end

  def create_valid?
    missing_params.empty?
  end

  def create_host
    create_params = host_params
    create_params.delete(:partner)

    host = Host.new create_params
    host.partner = host_partner

    if host.save
      render  json: host,
              status: :created,
              location: host_url(host.name)
    else
      render validation_failed host
    end
  end
end
