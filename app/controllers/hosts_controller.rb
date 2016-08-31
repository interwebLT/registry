class HostsController < SecureController
  def create
    host = Host.new host_params
    host.partner = current_partner

    host_try = Host.find_by_name(host.name)

    if host_try.nil?
      if host.save
        sync_create host

        render  json:     host,
                status:   :created,
                location: host_url(host.id)
      else
        render  validation_failed host
      end
    else
      render  json:     host_try,
              location: host_url(host_try.id)
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
    id = params[:id]

    host = Host.find_by name: id
    host ||= Host.find_by id: id if id.numeric?

    if host
      render json: host
    else
      render not_found
    end
  end

  private

  def host_params
    params.permit :name
  end

  def sync_create host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateHostJob.perform_later registry.url, host
    end
  end
end
