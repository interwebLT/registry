class Powerdns::DomainSerializer < ActiveModel::Serializer
  attributes  :id, :domain_id, :notified_serial, :name,
              :created_at, :updated_at
end
