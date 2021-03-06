class DomainsController < SecureController
  def index
    page = params[:page]
    if params[:name]
      render json: fetch_domain(page)
    elsif params[:search]
      render json: search_domains(page)
    elsif params[:get_count]
      render json: get_current_user_domains_count
    else
      render json: get_domains(page)
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
      domain_name  = domain.name
      partner_name = domain.partner.name
      ["reynan@dot.ph", "jm.mendoza@dot.ph", "ca.galamay@dot.ph"].map{|email|
        DomainDeleteMailer.delay_for(1.minute, queue: "registry_mailer").send_notice(domain_name, partner_name, email)
      }

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

  def valid_partner_domain
    unless params[:domains].nil?
      current_partner_domains = current_partner.domains.pluck(:name)
      invalid_domains = params[:domains] - current_partner_domains

      if invalid_domains.empty?
        render json: true
      else
        render json: "Domains #{invalid_domains.join(', ')} is not your registered domain(s)."
      end
    else
      render json: "Please enter a valid domain."
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

  def search_domains page
    get_domains(page).where('name like ?', "%#{params[:search]}%")
#      select do |domain|
#      domain.name.include? params[:search]
#    end
  end

  def fetch_domain page
    if !page.nil?
      Domain.where("name = '#{params[:name]}'").paginate page: page, per_page: 20
    else
      Domain.where("name = '#{params[:name]}'")
    end
  end

  def get_domains page
    if !page.nil?
      if current_partner.admin
        Domain.latest.paginate page: page, per_page: 20
      else
        current_partner.domains.order(:expires_at, :name).paginate page: page, per_page: 20
      end
    else
      if current_partner.admin
        Domain.latest
      else
        current_partner.domains.order(:expires_at, :name)
      end
    end
  end

  def get_current_user_domains_count 
    current_partner.domains.count
  end
end