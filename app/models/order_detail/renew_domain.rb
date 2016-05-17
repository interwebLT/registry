class OrderDetail::RenewDomain < OrderDetail
  alias_attribute :current_expires_at, :expires_at

  validates :domain, presence: true
  validates :period, presence: true

  def self.build params, partner
    self.new params
  end

  def action
    'domain_renew'
  end

  def complete!
    saved_domain = Domain.find_by! name: self.domain
    self.update! current_expires_at: saved_domain.expires_at

    domain = self.order.partner.renew_domain domain_name: self.domain, period: self.period

    if domain.errors.empty?
      self.product = domain.product
      self.status = COMPLETE_ORDER_DETAIL

      self.order.partner.ledgers.create order: self.order,
                                        amount: self.price * -1,
                                        activity_type: 'use'
    else
      self.status = ERROR_ORDER_DETAIL
    end

    self.save

    self.complete?
  end

  def reverse!
    domain = Domain.named(self.domain)

    domain.expires_at = (domain.expires_at - self.period.years)
    domain.save!

    self.order.partner.ledgers.create order: self.order,
                                      amount: self.price,
                                      activity_type: 'use'

    self.status = REVERSED_ORDER_DETAIL
    self.save!
  end

  def as_json options = nil
    {
      type: 'domain_renew',
      price: self.price.to_f,
      domain: self.domain,
      object: self.product.as_json,
      period: self.period.to_i
    }
  end

  def as_json_request
    {
      currency_code:  'USD',
      ordered_at: self.order.ordered_at.iso8601,
      order_details: [
        {
          type: self.action,
          domain: self.domain,
          period: self.period,
          current_expires_at: self.current_expires_at.iso8601
        }
      ]
    }
  end
end
