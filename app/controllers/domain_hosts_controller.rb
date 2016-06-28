class DomainHostsController < SecureController
  def create
    domain_id = create_params.delete :domain_id

    domain = Domain.named(domain_id)

    if domain
      create_domain_host domain
    else
      render not_found
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

  def create_params
    params.permit :domain_id, :name
  end

  def create_domain_host domain
    name = create_params.delete :name

    domain_host = DomainHost.new name: name, product: domain.product

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
end
