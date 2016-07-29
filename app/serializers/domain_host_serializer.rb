class DomainHostSerializer < ActiveModel::Serializer
  attributes :id, :name, :ip_list, :created_at, :updated_at
end
