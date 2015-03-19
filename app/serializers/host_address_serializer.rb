class HostAddressSerializer < ActiveModel::Serializer
  attributes :id, :address, :type, :created_at, :updated_at
end
