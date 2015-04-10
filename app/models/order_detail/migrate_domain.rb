class OrderDetail::MigrateDomain < OrderDetail
  validates :domain,            presence: true
  validates :authcode,          presence: true
  validates :registrant_handle, presence: true
  validates :registered_at,     presence: true
  validates :expires_at,        presence: true

  validate :registered_at_must_be_before_expires_at

  def self.build params, partner
    new params
  end

  def action
    'migrate_domain'
  end

  def complete!
    domain_name_array = self.domain.split '.', 2

    product = Product.create product_type: 'domain'

    domain = Domain.new name:               domain_name_array[0],
                        extension:          ".#{domain_name_array[1]}",
                        partner:            self.order.partner,
                        registered_at:      self.registered_at,
                        expires_at:         self.expires_at,
                        authcode:           self.authcode,
                        registrant_handle:  self.registrant_handle,
                        product:            product

    if domain.save
      self.order.partner.credits.create order: self.order,
                                        credits: 0.00,
                                        activity_type: 'use'

      self.status = COMPLETE_ORDER_DETAIL

    else
      self.status = ERROR_ORDER_DETAIL
    end

    self.save

    self.complete?
  end

  def as_json options = nil
    {
      type:               'migrate_domain',
      price:              self.price.to_f,
      domain:             self.domain,
      authcode:           self.authcode,
      registrant_handle:  self.registrant_handle,
      registered_at:      self.registered_at.iso8601,
      expires_at:         self.expires_at.iso8601
    }
  end

  private

  def registered_at_must_be_before_expires_at
    return if registered_at.nil? or expires_at.nil?

    errors.add :expires_at, I18n.t('errors.messages.invalid') if expires_at < registered_at
  end
end
