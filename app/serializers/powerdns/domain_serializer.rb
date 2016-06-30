class Powerdns::DomainSerializer < ActiveModel::DomainSerializer
  attributes  :id, :domain_id, :notified_serial, :name,
              :created_at, :updated_at
end