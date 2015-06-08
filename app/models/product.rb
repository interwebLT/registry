class Product < ActiveRecord::Base
  has_many :order_details
  has_many :domain_hosts
  has_many :object_activities

  has_one :domain
  has_one :object_status

  after_create :create_object_status

  def as_json options = nil
    {
      id:   self.domain.id,
      type: 'domain',
      name: self.domain.full_name
    }
  end

  private

  def create_object_status
    ObjectStatus.create product: self
  end
end
