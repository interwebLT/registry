class Product < ActiveRecord::Base
  has_many :order_details
  has_many :domain_hosts

  has_one :domain
  has_one :object_status

  after_create :create_object_status

  private

  def create_object_status
    ObjectStatus.create product: self
  end
end
