class DomainHostsController < SecureController
  REQUIRED_PARAMS = [:name]

  def create
    if create_valid?
      create_domain_host
    else
      render missing_fields missing_params
    end
  end

  def destroy
    domain_id = destroy_params.delete(:domain_id)

    domain = Domain.named(domain_id)

    if domain
      destroy_domain_host domain
    else
      render not_found
    end
  end

  private

  def create_params
    params.permit(:domain_id, :name)
  end

  def missing_params
    REQUIRED_PARAMS.reject { |key| create_params.include? key }
  end

  def create_valid?
    missing_params.empty?
  end

  def create_domain_host
    domain_host_params = create_params
    domain_id = domain_host_params.delete(:domain_id)

    domain = Domain.named(domain_id)

    if domain
      create_domain_host_for_existing_domain domain, domain_host_params
    else
      render not_found
    end
  end

  def create_domain_host_for_existing_domain domain, create_params
    domain_host = DomainHost.new create_params
    domain_host.product = domain.product

    if domain_host.save
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

  def sync_delete domain_host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client

      SyncDeleteDomainHostJob.perform_later registry.url,
                                            domain_host.product.domain.partner,
                                            domain_host.product.domain.name,
                                            domain_host.name
    end
  end
end
