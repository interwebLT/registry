class HostsController < SecureController
  before_action :update_host_address, only: [:create]

  def create
    host = Host.new host_params
    host.partner = current_partner

    if host.save
      sync_create host
      unless params[:ip_list].nil?
        create_host_address host, params[:ip_list]
      end

      render  json:     host,
              status:   :created,
              location: host_url(host.id)
    else
      render  validation_failed host
    end
  end

  def index
    if params[:search]
      hosts = search_host
    else
      if current_partner.admin?
        hosts = Host.all
      else
        hosts = current_partner.hosts
      end
    end
    render json: hosts
  end

  def show
    id = params[:id]

    host = Host.find_by name: id
    host ||= Host.find_by id: id if id.numeric?

    if host
      render json: host
    else
      render not_found
    end
  end

  def update
    unless host_params.empty?
      update_host
    else
      render bad_request
    end
  end

  private

  def host_params
    params.permit :name
  end

  def update_host
    id = params[:id]

    host = Host.find_by name: id
    host ||= Host.find_by id: id if id.numeric?
    if host
      update_existing_domain host
    else
      render not_found
    end
  end

  def update_existing_host host
    host_attributes = host_params

    partner = get_partner
    if partner
      host_attributes[:partner_id] = partner.id
      if host.update(host_attributes)
        render json: host
      else
        render validation_failed host
      end
    else
      render bad_request
    end
  end

  def get_partner
    partner_name = params[:partner_name]
    Partner.find_by_name partner_name
  end

  def sync_create host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateHostJob.perform_later registry.url, host
    end
  end

  def create_host_address host, ip_list
    if host.top_level_domain == "ph"
      if host.partner.name == current_partner.name
        ip_list = JSON.parse ip_list

        unless ip_list["ipv4"]["0"].empty? && ip_list["ipv6"]["0"].empty?
          ip_array = ip_list["ipv4"].map{|k,v|v} +  ip_list["ipv6"].map{|k,v|v} - [""]

          base_url         = Rails.configuration.api_url
          host_url         = "#{base_url}/hosts/#{host.name}"
          host_address_url = "#{host_url}/addresses"

          body    = {address: "", type:"" ,ip_list: ip_array}
          request = {headers: headers, body: body.to_json}

          process_response HTTParty.post host_address_url, request
        end
      end
    end
  end

  def update_host_address
    host = Host.find_by_name host_params["name"]

    unless host.nil?
      if host.top_level_domain == "ph"
        if host.partner.name == current_partner.name
          ip_list  = params[:ip_list] ? JSON.parse(params[:ip_list]) : ""
          base_url = Rails.configuration.api_url
          host_url = "#{base_url}/hosts/#{host.name}"

          unless ip_list.blank?
            unless ip_list["ipv4"]["0"].empty? && ip_list["ipv6"]["0"].empty?
              ip_array = ip_list["ipv4"].map{|k,v|v} +  ip_list["ipv6"].map{|k,v|v} - [""]

              host_address_array = host.host_addresses.map{|host| host.address}
              address_for_add    = ip_array - host_address_array
              address_for_remove = host_address_array - ip_array

              unless address_for_remove.empty?
                host_address_url = "#{host_url}/addresses/#{address_for_remove.first}?ip_list=#{address_for_remove.join(",")}"
                request = {headers:  headers}
                process_response HTTParty.delete host_address_url, request
              end

              unless address_for_add.empty?
                host_address_url = "#{host_url}/addresses"
                body    = {address: "", type:"" ,ip_list: address_for_add}
                request = {headers: headers, body: body.to_json}
                process_response HTTParty.post host_address_url, request
              end
            end
          end
        end
      end
    end
  end

  def search_host
    host = Host.find_by_name params[:search]

    if !host.nil?
      host
    else
      ""
    end
  end

  def process_response response
    JSON.parse response.body, symbolize_names: true
  end
end
