require 'test_helper'

describe Order do
  describe :new do
    subject { Order.new }

    specify { subject.pending?.must_equal true }
  end

  describe :valid? do
    subject { create :order }

    context :when_missing_partner do
      before do
        subject.partner = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:partner].must_equal ['invalid'] }
    end

    context :when_missing_order_details do
      subject { Order.new partner: partner }

      let(:partner) { create :partner }

      before do
        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:order_details].must_equal ['invalid'] }
    end
  end

  describe :associations do
    subject { create :order }

    specify { subject.partner.wont_be_nil }
    specify { subject.order_details.wont_be_empty }
  end

  describe :aliases do
    subject { build :order }

    specify { subject.ordered_at.must_equal subject.created_at }
  end

  describe :complete? do
    specify { Order.new(status: Order::COMPLETE_ORDER).complete?.must_equal true }
    specify { Order.new(status: Order::PENDING_ORDER).complete?.must_equal false }
    specify { Order.new(status: Order::ERROR_ORDER).complete?.must_equal false }
    specify { Order.new(status: Order::REVERSED_ORDER).complete?.must_equal false }
  end

  describe :pending? do
    specify { Order.new(status: Order::PENDING_ORDER).pending?.must_equal true }
    specify { Order.new(status: Order::COMPLETE_ORDER).pending?.must_equal false }
    specify { Order.new(status: Order::ERROR_ORDER).pending?.must_equal false }
    specify { Order.new(status: Order::REVERSED_ORDER).pending?.must_equal false }
  end

  describe :reversed? do
    specify { Order.new(status: Order::REVERSED_ORDER).reversed?.must_equal true }
    specify { Order.new(status: Order::PENDING_ORDER).reversed?.must_equal false }
    specify { Order.new(status: Order::COMPLETE_ORDER).reversed?.must_equal false }
    specify { Order.new(status: Order::ERROR_ORDER).reversed?.must_equal false }
  end

  describe :complete! do
    before do
      @order = create :order
      @order.complete!
    end

    subject { Order.find(@order.id) }

    specify { subject.complete?.must_equal true }
    specify { subject.completed_at.wont_be_nil }
    specify { subject.order_details.each { |od| od.complete?.must_equal true } }
  end

  describe :latest do
    subject { Order.latest }

    before do
      create :pending_register_domain_order, ordered_at: Time.now
      create :register_domain_order, ordered_at: Time.now
      create :renew_domain_order, ordered_at: Time.now
      create :replenish_credits_order, ordered_at: Time.now
      create :transfer_domain_order, ordered_at: Time.now
    end

    specify { subject.count.must_equal 5 }
    specify { subject[0].order_details.first.must_be_kind_of OrderDetail::TransferDomain }
    specify { subject[1].order_details.first.must_be_kind_of OrderDetail::ReplenishCredits }
    specify { subject[2].order_details.first.must_be_kind_of OrderDetail::RenewDomain }
    specify { subject[3].order_details.first.must_be_kind_of OrderDetail::RegisterDomain }
    specify { subject[4].order_details.first.must_be_kind_of OrderDetail::RegisterDomain }
    specify { subject[4].pending?.must_equal true }
  end

  describe :build do
    subject { Order.build params, partner }

    let(:partner) { create :partner }

    context :when_type_migration do
      let(:params) {
        {
          partner: partner.name,
          currency_code: 'USD',
          order_details: [
            {
              type: 'migrate_domain',
              domain: 'test.ph',
              registrant_handle: 'registrant',
              registered_at: '2015-01-01T00:00:00Z',
              expires_at: '2017-01-01T00:00:00Z'
            }
          ]
        }
      }

      specify { subject.order_details.first.must_be_kind_of OrderDetail::MigrateDomain }
    end
  end

  describe :reverse! do
    subject { create :renew_domain_order }

    before do
      create :domain, name: subject.order_details.first.domain

      subject.reverse!
    end

    specify { subject.reversed?.must_equal true }

    specify { Order.last.wont_equal subject }
    specify { Order.last.complete?.must_equal true }
    specify { Order.last.total_price.must_equal subject.total_price * -1 }
  end
end
