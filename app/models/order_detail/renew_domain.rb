class OrderDetail::RenewDomain < OrderDetail
  validates :domain, presence: true
  validates :period, presence: true

  def self.build params, partner
    order_detail = self.new
    order_detail.domain = params[:domain]
    order_detail.period = params[:period].to_i

    order_detail
  end

  def self.execute domain:, period:, renewed_at: Time.now
    saved_domain = Domain.named(domain)

    price = saved_domain.partner.pricing action: OrderDetail::RenewDomain.new.action, period: period

    o = Order.new partner: saved_domain.partner,
                  total_price: price,
                  ordered_at: renewed_at

    od = self.new price:      price,
                  domain:     saved_domain.name,
                  period:     period

    o.order_details << od
    o.save!

    o.complete!

    saved_domain.domain_activities.last.update! activity_at: renewed_at
  end

  def action
    'domain_renew'
  end

  def complete!
    domain = self.order.partner.renew_domain domain_name: self.domain, period: self.period

    if domain.errors.empty?
      self.product = domain.product
      self.status = COMPLETE_ORDER_DETAIL

      self.order.partner.credits.create order: self.order,
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

    self.order.partner.credits.create order: self.order,
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
end
