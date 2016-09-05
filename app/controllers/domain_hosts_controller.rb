class DomainHostsController < SecureController
  # before_action :create_host, only: [:create, :update]
  # before_action :delete_external_domain_host, only: [:update]

  def show
    domain_host = DomainHost.find params[:id]

    render json: domain_host
  end

  def create
    domain_id = create_params.delete :domain_id

    domain = Domain.named(domain_id)

    if domain
      create_domain_host domain
    else
      render not_found
    end
  end

  def update
    domain = Domain.find params[:domain_id]
    domain_host = DomainHost.find params[:id]
    if domain_host.update_attributes! update_params
      if @delete_sync
        sync_create domain_host
      end
      render  json: domain_host,
              location: domain_host_url(domain.full_name, domain_host.name)
    else
      render validation_failed domain_host
    end
  end

  def destroy
    domain_id = destroy_params.delete :domain_id

    domain = Domain.named(domain_id)

    if domain
      destroy_domain_host domain
    else
      render not_found
    end
  end

  private

  def update_params
    params.permit :name, :ip_list
  end

  def create_params
    params.permit :domain_id, :name, :ip_list
  end

  def create_domain_host domain
    ip_list = create_params.delete :ip_list
    name = create_params.delete :name
    domain_host = DomainHost.new name: name, product: domain.product, ip_list: ip_list
    if domain_host.save
      sync_create domain_host

      render  json: domain_host,
              status: :created,
              location: domain_host_url(domain.full_name, domain_host.name)
    else
      render validation_failed domain_host
    end
  end

  def destroy_params
    params.permit :domain_id, :id
  end

  def destroy_domain_host domain
    name = destroy_params.delete(:id)

    domain_host = domain.product.domain_hosts.find_by(name: name)

    if domain_host
      sync_delete domain_host

      render json: domain_host

      domain_host.destroy!
    else
      render not_found
    end
  end

  def sync_create domain_host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateDomainHostJob.perform_later registry.url, domain_host
    end
  end

  def sync_delete domain_host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncDeleteDomainHostJob.perform_later registry.url, domain_host
    end
  end

  def create_host
    base_url = Rails.configuration.api_url
    default_ip_list = {"ipv4":[],"ipv6":{"0":[]}}
    ip_list = if create_params["ip_list"].nil? then default_ip_list else create_params["ip_list"] end
    body = {
      name:    create_params["name"],
      ip_list: ip_list
    }
    request = {
      headers:  headers,
      body:     body.to_json
    }
    process_response HTTParty.post "#{base_url}/hosts", request
  end

  def delete_external_domain_host
    domain_host = DomainHost.find params[:id]
    new_name = params["name"]
    unless domain_host.name == new_name
      @delete_sync = true
      sync_delete domain_host
    end
  end

  def process_response response
    JSON.parse response.body, symbolize_names: true
  end
end
