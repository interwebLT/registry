class ObjectActivity < ActiveRecord::Base
  belongs_to :partner
  belongs_to :product

  validates :partner,     presence: true
  validates :product,     presence: true
  validates :activity_at, presence: true

  def self.latest
    self.all.includes(partner: :credits, product: [:domain, :deleted_domain]).order(id: :desc).limit(100)
  end
end
