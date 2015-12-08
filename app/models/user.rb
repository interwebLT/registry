class User < ActiveRecord::Base
  TIMEOUT = 15.minutes

  belongs_to :partner, foreign_key: :id

  has_many :authorizations

  attr_accessor :token

  def self.authorize! token
    conditions = { token: token, updated_at: (Time.now - TIMEOUT)..Time.now }

    Authorization.where(conditions).last
  end

  def password_matches input
    input == encrypted_password
  end

  def admin
    return partner.admin
  end

  def admin?
    return admin
  end

  def staff
    return partner.staff
  end

  def staff?
    return staff
  end
end
