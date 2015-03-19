class HostAddressesController < ApplicationController
  REQUIRED_PARAMS = [:address, :type]

  def create
    if create_valid?
      create_host_address
    else
      render missing_fields missing_create_params
    end
  end

  def destroy
    destroy_host_address
  end

  private

  def create_params
    params.permit(:host_id, :address, :type)
  end

  def missing_create_params
    REQUIRED_PARAMS.reject { |key| create_params.include? key }
  end

  def create_valid?
    missing_create_params.empty?
  end

  def destroy_params
    params.permit(:host_id, :id)
  end

  def create_host_address
    host_name = create_params.delete(:host_id)

    host = Host.find_by(name: host_name)

    if host
      create_host_address_for_existing_host host, create_params
    else
      render not_found
    end
  end

  def create_host_address_for_existing_host host, create_params
    host_address = HostAddress.new create_params
    host_address.host = host

    if host_address.save
      render  json: host_address,
              status: :created,
              location: host_address_url(host.name, host_address.address)
    else
      render validation_failed host_address
    end
  end

  def destroy_host_address
    host_address_params = destroy_params
    host_id = host_address_params.delete(:host_id)

    host = Host.find_by(name: host_id)

    if host
      destroy_host_address_for_existing_host host, host_address_params
    else
      render not_found
    end
  end

  def destroy_host_address_for_existing_host host, host_address_params
    address = host_address_params.delete(:id)

    host_address = host.host_addresses.find_by(address: address)

    if host_address
      render json: host_address

      host_address.destroy!
    else
      render not_found
    end
  end
end
