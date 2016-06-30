class Powerdns::RecordSerializer < ActiveModel::Serializer
  attributes  :id, :powerdns_domain_id, :name, :type, :content,
              :ttl, :prio, :change_date, :created_at, :updated_at
end