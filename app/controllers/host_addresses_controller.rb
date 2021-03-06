class HostAddressesController < SecureController
  before_action :set_ip_regex, only: [:create]

  def create
    host_id = create_params.delete :host_id
    host = Host.find_by name: host_id

    if host
      add_host_address to: host
    else
      render not_found
    end
  end

  def show
    id = params[:id]
    host_id = params[:host_id]

    host = Host.find_by name: host_id
    host ||= Host.find_by id: host_id if host_id.numeric?

    host_address = HostAddress.find_by_address_and_host_id(id, host.id)
    host_address ||= HostAddress.find_by id: id if id.numeric?

    if host_address
      render json: host_address
    else
      render not_found
    end
  end

  def destroy
    host_id = destroy_params.delete :host_id

    host = Host.find_by name: host_id

    if host
      remove_host_address from: host
    else
      render not_found
    end
  end

  private

  def create_params
    params.permit :host_id, :address, :type
  end

  def destroy_params
    params.permit :host_id, :id
  end

  def add_host_address to:
    host = to
    if host.top_level_domain == "ph"
      if params[:ip_list].nil?
        address = create_params.delete :address
        type    = create_params.delete :type

        host_address = host.host_addresses.build address: address, type: type

        if host_address.save
          sync_create host_address

          render  json:     host_address,
                  status:   :created,
                  location: host_address_url(host.name, host_address.address)
        else
          render validation_failed host_address
        end
      else
        ip_array = params[:ip_list]

        ip_array.map {|address|
          type         = if (address =~ @ipv4) then "v4" else "v6" end
          host_address = host.host_addresses.build address: address, type: type
          host_address.sinag_update = true
          host_address.save
        }
        sync_create_multiple host, ip_array
        render  json: host_address
      end
    end
  end

  def remove_host_address from:
    host = from
    if params[:ip_list].nil?
      address = destroy_params.delete :id

      host_address = host.host_addresses.find_by address: address

      if host_address
        sync_delete host_address
        render json: host_address
        host_address.destroy!
      else
        render not_found
      end
    else
      ip_array = params[:ip_list].split(",")
      sync_delete_multiple host, ip_array
      ip_array.map {|address|
        host_address = host.host_addresses.find_by address: address
        host_address.sinag_update = true
        host_address.destroy!
      }
      render  json: {}
    end
  end

  def sync_create host_address
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateHostAddressJob.perform_later registry.url, host_address
    end
  end

  def sync_delete host_address
    host = host_address.host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncDeleteHostAddressJob.perform_later registry.url, host_address.address, host
    end
  end

  def sync_create_multiple host, ip_array
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateBulkHostAddressJob.perform_later registry.url, host, ip_array
    end
  end

  def sync_delete_multiple host, ip_array
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncDeleteBulkHostAddressJob.perform_later registry.url, host, ip_array
    end
  end

  def set_ip_regex
    @ipv4 = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  end
end
