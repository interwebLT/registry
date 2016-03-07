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
end
