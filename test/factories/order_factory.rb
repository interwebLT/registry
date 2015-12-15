FactoryGirl.define do
  factory :base_order, class: Order do
    partner
    total_price 150.00
    sequence(:order_number) do |n|
      n.to_s(16).rjust(10, '0').upcase
    end
    fee 0.00
    status Order::COMPLETE_ORDER
    ordered_at '2015-02-27 14:30'.in_time_zone
    updated_at '2015-02-27 14:30'.in_time_zone
    completed_at '2015-02-27 14:30'.in_time_zone

    factory :order, aliases: [:complete_order] do
      before :create do |order, evaluator|
        order.order_details << (build :renew_domain_order_detail, order: order)

        create :ledger, order: order
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
      
      factory :pending_renew_domain_order do
        status Order::PENDING_ORDER
      end
    end

    factory :transfer_domain_order do
      before :create do |order|
        order_detail = build :transfer_domain_order_detail, order: order
        order.total_price = order_detail.price

        order.order_details << order_detail
      end
    end

    factory :refund_order do
      total_price -35.00

      before :create do |order|
        order_detail = build :refund_order_detail, order: order
        order.total_price = order_detail.price

        order.order_details << order_detail
      end

      after :create do |order|
        refunded_order_detail = order.order_details.first.refunded_order_detail
        refunded_order = refunded_order_detail.order

        refunded_order.status = Order::REVERSED_ORDER
        refunded_order.partner = order.partner
        refunded_order.total_price = refunded_order_detail.price
        refunded_order.save!

        OrderDetail::RenewDomain.find_by(order: refunded_order).destroy!
#        OrderDetail::ReplenishCredits.find_by(order: refunded_order).destroy!
      end
    end
  end
end
