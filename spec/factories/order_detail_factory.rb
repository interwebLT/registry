FactoryGirl.define do
  factory :order_detail do
    order
    product
    type OrderDetail::RegisterDomain
    price 150.00
    status OrderDetail::COMPLETE_ORDER_DETAIL

    factory :order_detail_for_domain do
      after :create do |order_detail, evaluator|
        create :domain, product: order_detail.product
      end
    end

    factory :register_domain_order_detail, class: OrderDetail::RegisterDomain do
      type OrderDetail::RegisterDomain.name
      price 35.00
      domain 'domains.ph'
      authcode 'ABC123'
      period 2
      registrant_handle 'domains_r'
    end

    factory :renew_domain_order_detail, class: OrderDetail::RenewDomain,
                                        aliases: [:refunded_order_detail] do
      type OrderDetail::RenewDomain
      price 35.00
      domain 'domain.ph'
      period 1
    end

    factory :transfer_domain_order_detail, class: OrderDetail::TransferDomain do
      type OrderDetail::TransferDomain
      price 15.00
      domain 'domain.ph'
      registrant_handle 'contact'
    end

    factory :migrate_domain_order_detail, class: OrderDetail::MigrateDomain do
      type OrderDetail::MigrateDomain
      price 0.00
      domain 'domain.ph'
      authcode 'ABC123'
      registrant_handle 'domains_r'
      registered_at '2015-04-10 11:00'.in_time_zone
      expires_at '2017-04-10 11:00'.in_time_zone
    end

    factory :refund_order_detail, class: OrderDetail::Refund do
      type OrderDetail::Refund
      price -35.00
      refunded_order_detail

      factory :pending_refund_order_detail do
        status OrderDetail::PENDING_ORDER_DETAIL
      end
    end
  end
end
