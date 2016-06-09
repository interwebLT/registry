class Host < ActiveRecord::Base
  belongs_to :partner

  has_many :host_addresses

  validates :partner, presence: true
  validates :name,    presence: true
  validates :name,    uniqueness: true
end
