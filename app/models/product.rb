class Product < ActiveRecord::Base
  has_many :order_details
  has_many :domain_hosts
  has_many :object_activities

  has_one :domain
  has_one :deleted_domain
  has_one :object_status

  def as_json options = nil
    if self.domain
      domain_json
    elsif self.deleted_domain
      deleted_domain_json
    end
  end

  private

  def domain_json
    {
      id:   self.domain.id,
      type: 'domain',
      name: self.domain.name
    }
  end

  def deleted_domain_json
    {
      id:   self.deleted_domain.id,
      type: 'deleted_domain',
      name: self.deleted_domain.name
    }
  end
end
