class DomainHostsController < SecureController
  before_action :get_existing_domain_hosts, only: [:create]
  before_action :create_host, only: [:create, :update]
  before_action :delete_external_domain_host, only: [:update]

  def show
    domain_host = DomainHost.find params[:id]
    render json: domain_host
  end

  def create
    domain_id = create_params.delete :domain_id
    domain = Domain.named(domain_id)

    unless params[:troy_domain_hosts].nil?
      troy_domain_hosts = params[:troy_domain_hosts]
      bulk_create_domain_host troy_domain_hosts, domain
    else
      if domain
        create_domain_host domain
      else
        render not_found
      end
    end
  end

  def update
    domain = Domain.find params[:domain_id]
    domain_host = DomainHost.find params[:id]
    if domain_host.update_attributes! update_params
      if @delete_sync
        sync_update domain_host, @old_domain_host_name
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
      render domain_already_deleted
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
      render already_deleted
    end
  end

  def delete_external_domain_host
    domain_host = DomainHost.find params[:id]
    new_name = params["name"]
    unless domain_host.name == new_name
      @old_domain_host_name = domain_host.name
      @delete_sync = true
    end
  end

  def create_host
    base_url = Rails.configuration.api_url

    unless params[:troy_domain_hosts].nil?
      params[:troy_domain_hosts].map{|domain_host|
        unless domain_host[0].blank?
          unless @existing_domain_hosts.include? domain_host[0]
            ipv4 = domain_host[1]["addresses"]["ipv4"] ? domain_host[1]["addresses"]["ipv4"] : ""
            ipv6 = domain_host[1]["addresses"]["ipv6"] ? domain_host[1]["addresses"]["ipv6"] : ""
            ip_list = {"ipv4":{"0": ipv4},"ipv6":{"0": ipv6}}.to_json
            save_host domain_host[0], ip_list, base_url
          end
        end
      }
    else
      default_ip_list = {"ipv4":{"0": ""},"ipv6":{"0": ""}}.to_json
      ip_list = if create_params["ip_list"].nil? then default_ip_list else create_params["ip_list"] end
      save_host create_params["name"], ip_list, base_url
    end
  end

  def bulk_create_domain_host troy_domain_hosts, domain
    domain_host_for_delete = []
    domain_host_for_add    = []
    domain.product.domain_hosts.map{|domain_host|
      unless troy_domain_hosts.map{|domain_host| domain_host[0]}.include? domain_host.name
        domain_host_for_delete << domain_host.name
        domain_host.destroy!
      end
    }

    troy_domain_hosts.map{|domain_host|
      unless domain_host[0].blank?
        unless @existing_domain_hosts.include? domain_host[0]
          ipv4 = domain_host[1]["addresses"]["ipv4"] ? domain_host[1]["addresses"]["ipv4"] : ""
          ipv6 = domain_host[1]["addresses"]["ipv6"] ? domain_host[1]["addresses"]["ipv6"] : ""
          ip_list = {"ipv4":{"0": ipv4},"ipv6":{"0": ipv6}}.to_json
          domain_host_for_add << domain_host[0]
          domain_host = DomainHost.new name: domain_host[0], product: domain.product, ip_list: ip_list
          domain_host.save!
        end
      end
    }
    if !domain_host_for_add.empty? and !domain_host_for_delete.empty?
      sync_create_delete_bulk domain, domain_host_for_delete, domain_host_for_add
    end
    render  json: domain
  end

  def sync_create domain_host
    ExternalRegistry.all.each do |registry|
      # next if registry.name == current_partner.client
      # next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateDomainHostJob.perform_later registry.url, domain_host
    end
  end

  def sync_update domain_host, old_domain_host_name
    ExternalRegistry.all.each do |registry|
      # next if registry.name == current_partner.client
      # next if ExcludedPartner.exists? name: current_partner.name

      SyncUpdateDomainHostJob.perform_later registry.url, domain_host, old_domain_host_name
    end
  end

  def sync_delete domain_host
    ExternalRegistry.all.each do |registry|
      # next if registry.name == current_partner.client
      # next if ExcludedPartner.exists? name: current_partner.name

      SyncDeleteDomainHostJob.perform_later registry.url, domain_host
    end
  end

  def sync_create_delete_bulk domain, domain_host_for_delete, domain_host_for_add
    ExternalRegistry.all.each do |registry|
      # next if registry.name == current_partner.client
      # next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateDeleteBulkDomainHostJob.perform_later registry.url, domain, domain_host_for_delete, domain_host_for_add
    end
  end

  def get_existing_domain_hosts
    domain_id = create_params.delete :domain_id
    domain = Domain.named(domain_id)
    @existing_domain_hosts = domain.product.domain_hosts.map{|domain_host| domain_host.name}
  end

  def save_host name, ip_list, base_url
    unless Host.exists? name: name
      body = {
        name:    name,
        ip_list: ip_list
      }
      request = {
        headers:  headers,
        body:     body.to_json
      }
      process_response HTTParty.post "#{base_url}/hosts", request
    end
  end

  def process_response response
    JSON.parse response.body, symbolize_names: true
  end
end
