class HostSerializer < ActiveModel::Serializer
  attributes :id, :partner, :name, :host_addresses, :created_at, :updated_at

  def partner
    object.partner.name
  end

  def host_addresses
    object.host_addresses.order(address: :asc).collect do |host_address|
      {
        address: host_address.address,
        type: host_address.type
      }
    end
  end
end
