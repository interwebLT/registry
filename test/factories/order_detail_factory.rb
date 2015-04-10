FactoryGirl.define do
  factory :order_detail do
    order
    product
    type OrderDetail::ReplenishCredits.name
    price 150.00
    status OrderDetail::COMPLETE_ORDER_DETAIL

    factory :order_detail_for_domain do
      after :create do |order_detail, evaluator|
        create :domain, product: order_detail.product
      end
    end

    factory :replenish_credits_order_detail, class: OrderDetail::ReplenishCredits  do
      type OrderDetail::ReplenishCredits.name
      period 150
    end

    factory :register_domain_order_detail, class: OrderDetail::RegisterDomain do
      type OrderDetail::RegisterDomain.name
      price 35.00
      domain 'domains.ph'
      period 2
      registrant_handle 'domains_r'
      registered_at '2015-02-17 00:00'.in_time_zone
    end

    factory :renew_domain_order_detail, class: OrderDetail::RenewDomain do
      type OrderDetail::RenewDomain
      price 35.00
      domain 'domain.ph'
      period 1
      renewed_at '2015-02-14 01:01 AM'.in_time_zone
    end

    factory :transfer_domain_order_detail, class: OrderDetail::TransferDomain do
      type OrderDetail::TransferDomain
      price 15.00
      domain 'domain.ph'
    end

    factory :migrate_domain_order_detail, class: OrderDetail::MigrateDomain do
      type OrderDetail::MigrateDomain
      price 0.00
      domain 'domain.ph'
      registrant_handle 'domains_r'
      registered_at '2015-04-10 11:00'.in_time_zone
      expires_at '2017-04-10 11:00'.in_time_zone
    end
  end
end
