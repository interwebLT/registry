class RegistryConsole
  def self.register_domain  partner:,
                            domain:,
                            authcode:,
                            period:,
                            registrant_handle:,
                            at: Time.current,
                            skip_create: false
    owning_partner = Partner.find_by! name: partner

    price = owning_partner.pricing action: 'domain_create', period: period

    order = Order.new partner: owning_partner,
                      total_price:  price,
                      ordered_at: at

    order_detail = OrderDetail::RegisterDomain.new  price: price,
                                                    domain: domain,
                                                    authcode: authcode,
                                                    period: period,
                                                    registrant_handle:  registrant_handle

    order.order_details << order_detail
    order.save!

    unless skip_create
      order.complete!

      Domain.named(domain).domain_activities.last.update! activity_at: at
    else
      order.update! status: Order::COMPLETE_ORDER, completed_at: Time.current
      order_detail.update! status: OrderDetail::COMPLETE_ORDER_DETAIL
    end

    order
  end

  def self.renew_domain domain:, period:, at: Time.current
    saved_domain = Domain.named(domain)

    price = saved_domain.partner.pricing action: 'domain_renew', period: period

    order = Order.new partner: saved_domain.partner,
                      total_price:  price,
                      ordered_at: at

    order_detail = OrderDetail::RenewDomain.new price:  price,
                                                domain: saved_domain.name,
                                                period: period

    order.order_details << order_detail
    order.save!

    order.complete!

    saved_domain.domain_activities.last.update! activity_at: at

    order
  end

  def self.transfer_domain domain:, to:, fee: true, at: Time.current, handle:
    partner = Partner.find_by! name: to

    price = fee ? (partner.pricing action: 'transfer_domain', period: 0) : 0.00.money

    order = Order.new partner:      partner,
                      total_price:  price,
                      ordered_at:   at

    order_detail = OrderDetail::TransferDomain.new  price:              price,
                                                    domain:             domain,
                                                    registrant_handle:  handle

    order.order_details << order_detail
    order.save!

    order.complete!

    Domain.named(domain).domain_activities.last.update! activity_at: at

    order
  end
end
