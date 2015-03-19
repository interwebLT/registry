class DomainActivity < ActiveRecord::Base
  self.table_name = 'domain_activity'

  belongs_to :partner
  belongs_to :domain

  def self.latest
    self.all.includes(:domain).order(id: :desc).limit(1000)
  end
end
