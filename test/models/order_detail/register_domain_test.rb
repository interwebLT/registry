require 'test_helper'

describe OrderDetail::RegisterDomain do
  describe :build do
    subject { OrderDetail.build params, partner }

    let(:params) {
      {
        type: OrderDetail::RegisterDomain.new.action,
        domain: 'domains.ph',
        period: 2,
        registrant_handle: 'domains_registrant'
      }
    }

    let(:partner) { create :complete_partner }

    specify { subject.must_be_kind_of OrderDetail::RegisterDomain }
    specify { subject.price.must_equal 70.00.money }
    specify { subject.domain.must_equal 'domains.ph' }
    specify { subject.period.must_equal 2 }
    specify { subject.registrant_handle.must_equal 'domains_registrant' }
    specify { subject.credits.must_equal 0.00.money }
  end

  describe :complete do
    before do
      @registrant = create :contact, handle: 'registrant'
      @order_detail = create :register_domain_order_detail, registrant_handle: registrant_handle
      @order_detail.complete!
    end

    subject { @order_detail }

    let(:registrant_handle) { @registrant.handle }
    let(:saved_domain) { Domain.named(@order_detail.domain) }
    let(:latest_ledger_entry) { @order_detail.order.partner.credits.last }

    context :when_successful do
      specify { subject.complete?.must_equal true }
      specify { saved_domain.wont_be_nil }
      specify { saved_domain.registered_at.must_equal subject.registered_at }
      specify { latest_ledger_entry.activity_type.must_equal 'use' }
      specify { latest_ledger_entry.credits.must_equal BigDecimal.new(-35) }
    end

    context :when_registrant_does_not_exist do
      let(:registrant_handle) { 'dne' }

      specify { subject.complete?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
      specify { saved_domain.must_be_nil }
    end
  end

  describe :valid? do
    subject {
      OrderDetail::RegisterDomain.new domain: 'test.ph',
                                      period: 2,
                                      registrant_handle: 'registrant',
                                      price: 35.money,
                                      registered_at: Time.now
    }

    context :when_domain_missing do
      before do
        subject.domain = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:domain].must_equal ['invalid'] }
    end

    context :when_period_missing do
      before do
        subject.period = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:period].must_equal ['invalid'] }
    end

    context :when_registrant_handle_missing do
      before do
        subject.registrant_handle = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
    end

    context :when_registered_at_missing do
      before do
        subject.registered_at = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registered_at].must_equal ['invalid'] }
    end
  end

  describe :as_json do
    subject { order_detail.as_json }

    let(:order_detail) {
      OrderDetail::RegisterDomain.new domain: 'test.ph',
                                      period: 2,
                                      registrant_handle: 'registrant',
                                      price: 35.money,
                                      registered_at: '2015-02-18 7:00 PM'.in_time_zone
    }

    let(:expected_json) {
      {
        type: 'domain_create',
        price: 35.0,
        domain: 'test.ph',
        period: 2,
        registrant_handle: 'registrant',
        registered_at: '2015-02-18T19:00:00Z'
      }
    }

    specify { subject.must_equal expected_json }
  end
end
