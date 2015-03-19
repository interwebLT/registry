FactoryGirl.define do
  factory :base_order, class: Order do
    partner
    total_price 150.00
    fee 0.00
    status Order::COMPLETE_ORDER
    ordered_at '2015-02-27 14:30'.in_time_zone
    updated_at '2015-02-27 14:30'.in_time_zone
    completed_at '2015-02-27 14:30'.in_time_zone

    factory :order, aliases: [:complete_order, :replenish_credits_order] do
      before :create do |order, evaluator|
        order.order_details << (build :replenish_credits_order_detail, order: order)
      end

      factory :pending_replenish_credits_order do
        status Order::PENDING_ORDER
      end
    end

    factory :register_domain_order do
      total_price 35.00

      before :create do |order, evaluator|
        order.order_details << (build :register_domain_order_detail, order: order)
      end

      factory :pending_register_domain_order do
        status Order::PENDING_ORDER
      end
    end

    factory :renew_domain_order do
      total_price 35.00

      before :create do |order, evaluator|
        order.order_details << (build :renew_domain_order_detail, order: order)
      end
    end

    factory :transfer_domain_order do
      before :create do |order|
        order_detail = build :transfer_domain_order_detail, order: order
        order.total_price = order_detail.price

        order.order_details << order_detail
      end
    end
  end
end
