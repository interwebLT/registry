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
    destroy_domain_host
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
    params.permit(:domain_id, :id)
  end

  def destroy_domain_host
    domain_host_params = destroy_params
    domain_id = domain_host_params.delete(:domain_id)

    domain = Domain.named(domain_id)

    if domain
      destroy_domain_host_for_existing_domain domain, domain_host_params
    else
      render not_found
    end
  end

  def destroy_domain_host_for_existing_domain domain, destroy_params
    name = destroy_params.delete(:id)

    domain_host = domain.product.domain_hosts.find_by(name: name)

    if domain_host
      domain_host.sync! unless current_user.admin

      render json: domain_host

      domain_host.destroy!
    else
      render not_found
    end
  end
end
