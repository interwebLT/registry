class User < ActiveRecord::Base
  self.table_name = 'partners'

  TIMEOUT = 15.minutes

  belongs_to :partner, foreign_key: :id

  has_many :authorizations

  alias_attribute :username, :name
  alias_attribute :password, :encrypted_password

  attr_accessor :token

  def self.authorize! token
    conditions = { token: token, updated_at: (Time.now - TIMEOUT)..Time.now }

    Authorization.where(conditions).last
  end
end
