class MigratedDomain < ActiveRecord::Base
  belongs_to :partner

  after_create :migrate_domain

  validates :name,              presence: true
  validates :partner,           presence: true
  validates :registrant_handle, presence: true
  validates :registered_at,     presence: true
  validates :expires_at,        presence: true

  validate  :registered_at_must_be_before_expires_at

  private

  def migrate_domain
    return if Domain.exists? name: name

    product = Product.create product_type: 'domain'

    partner.domains.create  name:               name,
                            registrant_handle:  registrant_handle,
                            registered_at:      registered_at,
                            expires_at:         expires_at,
                            authcode:           authcode,
                            product:            product
  end

  def registered_at_must_be_before_expires_at
    return if registered_at.nil? or expires_at.nil?

    errors.add :expires_at, I18n.t('errors.messages.invalid') if expires_at < registered_at
  end
end
