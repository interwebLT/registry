class DomainsController < SecureController
  def index
    if params[:name]
      render json: fetch_domain
    elsif params[:search]
      render json: search_domains
    else
      render json: get_domains
    end
  end

  def show
    domain = (Domain.find_by(id: params[:id]) || Domain.find_by(name: params[:id]))

    if domain and ((domain.partner == current_user.partner) or current_user.admin)
      render json: domain, serializer: DomainInfoSerializer
    else
      render not_found
    end
  end

  def update
    unless domain_params.empty?
      update_domain
    else
      render bad_request
    end
  end

  private

  def update_domain
    domain = Domain.named(params[:id])

    if domain
      update_existing_domain domain
    else
      render not_found
    end
  end

  def update_existing_domain domain
    if domain.update(domain_params)
      render json: domain
    else
      render validation_failed domain
    end
  end

  def domain_params
    params.permit(:registrant_handle, :authcode, :admin_handle, :billing_handle, :tech_handle, :client_hold, :client_delete_prohibited, :client_renew_prohibited, :client_transfer_prohibited, :client_update_prohibited)
  end

  def search_domains
    get_domains.select do |domain|
      domain.name.include? params[:search]
    end
  end

  def fetch_domain
    Domain.where("name = '#{params[:name]}'")


  end

  def get_domains
    if current_user.admin
      Domain.latest
    else
      current_user.partner.domains.order(:expires_at, :name)
    end
  end
end
