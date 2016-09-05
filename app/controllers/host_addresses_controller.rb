class HostAddressesController < SecureController
  def create
    host_id = create_params.delete :host_id
    host = Host.find_by name: host_id

    if host
      add_host_address to: host
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
        type         = if address.length > 15 then "v6" else "v4" end
        host_address = host.host_addresses.build address: address, type: type
        host_address.save
      }
      sync_create_multiple host, ip_array
      render  json: host
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
      ip_array.map {|address|
        host_address = host.host_addresses.find_by address: address
        host_address.destroy!
      }
      sync_delete_multiple host, ip_array
      render  json: host
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
end
