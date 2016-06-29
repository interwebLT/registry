class Powerdns::Domain < ActiveRecord::Base
	belongs_to :domain
	has_many :powerdns_records, class_name: Powerdns::Record, dependent: :destroy
end
