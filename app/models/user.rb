require 'bcrypt'

class User < ActiveRecord::Base
  before_create :set_registered_at 

  TIMEOUT = 15.minutes

  belongs_to :partner

  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  validates :name, presence: true

  has_many :authorizations

  attr_accessor :token

  def self.authorize! token
    conditions = { token: token, updated_at: (Time.now - TIMEOUT)..Time.now }

    Authorization.where(conditions).last
  end

  def password_matches input
    encrypted_password == BCrypt::Engine.hash_secret(input, salt)
  end

  def password=(pw)
    if pw.nil? || pw.blank?
      return
    end
    self.salt = BCrypt::Engine.generate_salt
    self.encrypted_password = BCrypt::Engine.hash_secret(pw, salt)
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

  private
  def set_registered_at
    if self.registered_at.nil?
      self.registered_at = Time.now
    end
  end
end
