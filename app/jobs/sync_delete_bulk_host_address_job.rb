class SyncDeleteBulkHostAddressJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, host, ip_array
    new_ip_list = []
    header   = {"Content-Type"=>"application/json", "Accept"=>"application/json", "Authorization"=>"Token token=#{host.partner.name}"}
    headers  = {headers: header}

    host_url = "#{url}/hosts/#{host.name}"

    ip_array.each do |host_address|
      host_url_check = "#{host_url}/addresses/#{host_address}"

      host_address_available_in_cocca = process_response HTTParty.get(host_url_check, headers)

      if host_address_available_in_cocca
        new_ip_list << host_address
      end
    end

    unless new_ip_list.empty?
      host_address_url  = "#{host_url}/addresses/#{new_ip_list.first}?ip_list=#{new_ip_list.join(",")}"
      delete host_address_url, token: host.partner.name
    end
  end

  def process_response response
    if (400..599).include? response.code
      false
    else
      true
    end
  end
end
