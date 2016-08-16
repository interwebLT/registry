class HostAddress < ActiveRecord::Base
  attr_accessor :_type_disabled
  self.inheritance_column = :_type_disabled

  belongs_to :host

  validates :address, presence: true
  validates :address, uniqueness: { scope: [:address, :host] }
  validates :type, inclusion: { in: %w(v4 v6) }
end
