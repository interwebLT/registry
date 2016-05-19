class ExternalRegistry < ActiveRecord::Base
  validates :name,  presence: true, uniqueness: true
  validates :url,   presence: true
end
