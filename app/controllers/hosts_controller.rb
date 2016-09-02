class HostsController < SecureController
  before_action :update_host_address, only: [:create]

  def create
    host = Host.new host_params
    host.partner = current_partner

    if host.save
      create_host_address host, params[:ip_list]
      sync_create host

      render  json:     host,
              status:   :created,
              location: host_url(host.id)
    else
      render  validation_failed host
    end
  end

  def index
    unless current_partner.admin?
      render json: []
      return
    end

    render json: Host.all
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

  private

  def host_params
    params.permit :name
  end

  def sync_create host
    ExternalRegistry.all.each do |registry|
      next if registry.name == current_partner.client
      next if ExcludedPartner.exists? name: current_partner.name

      SyncCreateHostJob.perform_later registry.url, host
    end
  end

  def create_host_address host, ip_list
    ip_list = JSON.parse ip_list

    unless ip_list["ipv4"]["0"].empty? && ip_list["ipv6"]["0"].empty?
      ip_array = ip_list["ipv4"].map{|k,v|v} +  ip_list["ipv6"].map{|k,v|v}

      ip_array.map {|address|
        unless address.empty?
          base_url         = Rails.configuration.api_url
          host_url         = "#{base_url}/hosts/#{host.name}"
          host_address_url = "#{host_url}/addresses"
          address_type     = if address.length > 15 then "v6" else "v4" end

          body    = {address: address, type: address_type}
          request = {headers: headers, body: body.to_json}

          process_response HTTParty.post host_address_url, request
        end
      }
    end
  end

  def update_host_address
    host = Host.find_by_name host_params["name"]

    unless host.nil?
      ip_list = JSON.parse params[:ip_list]
      base_url         = Rails.configuration.api_url
      host_url         = "#{base_url}/hosts/#{host.name}"

      unless ip_list["ipv4"]["0"].empty? && ip_list["ipv6"]["0"].empty?
        ip_array = ip_list["ipv4"].map{|k,v|v} +  ip_list["ipv6"].map{|k,v|v}

        host_address_array = host.host_addresses.map{|host| host.address}
        address_for_add    = ip_array - host_address_array
        address_for_remove = host_address_array - ip_array

        unless address_for_remove.empty?
          host.host_addresses.map{|host_address|
            if address_for_remove.include?(host_address.address)
              host_address_url = "#{host_url}/addresses/#{host_address.address}"
              request = {headers:  headers}
              process_response HTTParty.delete host_address_url, request
            end
          }
        end

        unless address_for_add.empty?
          address_for_add.map{ |address|
            unless address.empty?
              host_address_url = "#{host_url}/addresses"
              address_type     = if address.length > 15 then "v6" else "v4" end
              body    = {address: address, type: address_type}
              request = {headers: headers, body: body.to_json}
              process_response HTTParty.post host_address_url, request
            end
          }
        end
      end
    end
  end

  def process_response response
    JSON.parse response.body, symbolize_names: true
  end
end
