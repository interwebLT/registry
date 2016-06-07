class MigratedDomain < ActiveRecord::Base
  belongs_to :partner

  after_create :migrate_domain

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
end
