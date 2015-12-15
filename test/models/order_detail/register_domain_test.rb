require 'test_helper'

describe OrderDetail::RegisterDomain do
  describe :build do
    subject { OrderDetail.build params, partner }

    let(:params) {
      {
        type: OrderDetail::RegisterDomain.new.action,
        domain: 'domains.ph',
        authcode: 'ABC123',
        period: 2,
        registrant_handle: 'domains_registrant'
      }
    }

    let(:partner) { create :complete_partner }

    specify { subject.valid?.must_equal true }
    specify { subject.must_be_kind_of OrderDetail::RegisterDomain }
    specify { subject.price.must_equal 70.00.money }
    specify { subject.domain.must_equal 'domains.ph' }
    specify { subject.authcode.must_equal 'ABC123' }
    specify { subject.period.must_equal 2 }
    specify { subject.registrant_handle.must_equal 'domains_registrant' }
    specify { subject.credits.must_equal 0.00.money }
  end

  describe :complete! do
    subject { create :register_domain_order_detail }

    before do
      create :contact, handle: subject.registrant_handle
    end

    let(:saved_domain) { Domain.named(subject.domain) }
    let(:latest_ledger_entry) { subject.order.partner.ledgers.last }

    context :when_successful do
      before do
        subject.complete!
      end

      specify { subject.complete?.must_equal true }

      specify { saved_domain.wont_be_nil }
      specify { saved_domain.registered_at.must_equal subject.order.ordered_at }
      specify { saved_domain.authcode.must_equal subject.authcode }
      specify { subject.product.must_equal saved_domain.product }

      specify { latest_ledger_entry.activity_type.must_equal 'use' }
      specify { latest_ledger_entry.amount.must_equal -35.00.money }
    end

    context :when_registrant_does_not_exist do
      before do
        subject.registrant_handle = 'dne'
        subject.save

        subject.complete!
      end

      specify { subject.complete?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }

      specify { saved_domain.must_be_nil }
    end
  end

  describe :valid? do
    subject { build :register_domain_order_detail }

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

    context :when_no_authcode do
      before do
        subject.authcode = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:authcode].must_equal ['invalid'] }
    end
  end

  describe :as_json do
    subject { build :register_domain_order_detail }

    let(:expected_json) {
      {
        type: 'domain_create',
        price: 35.0,
        domain: 'domains.ph',
        object: nil,
        authcode: 'ABC123',
        period: 2,
        registrant_handle: 'domains_r'
      }
    }

    specify { subject.as_json.must_equal expected_json }
  end
end
