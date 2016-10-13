class Epp::Partner < ActiveRecord::Base
  self.table_name = 'partner'

  alias_attribute :username, :name

  validates :name,  presence: true
  validates :password,  presence: true

end
