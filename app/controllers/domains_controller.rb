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
    id = params[:id]

    domain = Domain.find_by name: id
    domain ||= Domain.find_by id: id if id.numeric?

    if domain and ((domain.partner == current_partner) or current_partner.admin)
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

  def destroy
    domain = Domain.named(params[:id])

    if domain
      domain.destroy

      render json: domain, serializer: DomainInfoSerializer
    else
      render not_found
    end
  end

  def check_nameserver_authorization
    unless params[:domain].nil? && params[:partner].nil? && params[:host].nil?
      domain  = Domain.find_by_name params[:domain]
      partner = params[:partner]

      unless domain.nil?
        if domain.partner.name != partner
          host = Host.find_by_name params[:host]

          if host.nil?
            render json: "false"
          else
            render json: "true"
          end
        else
          render json: "true"
        end
      else
        render json: "true"
      end
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
    params.permit :registrant_handle, :authcode, :admin_handle, :billing_handle, :tech_handle,
                  :client_hold, :client_delete_prohibited, :client_renew_prohibited, :client_transfer_prohibited, :client_update_prohibited,
                  :server_hold, :server_delete_prohibited, :server_renew_prohibited, :server_transfer_prohibited, :server_update_prohibited, :status_pending_transfer
  end

  def search_domains
    get_domains.where('name like ?', "%#{params[:search]}%")
#      select do |domain|
#      domain.name.include? params[:search]
#    end
  end

  def fetch_domain
    Domain.where("name = '#{params[:name]}'")


  end

  def get_domains
    if current_partner.admin
      Domain.latest
    else
      current_partner.domains.order(:expires_at, :name)
    end
  end
end
