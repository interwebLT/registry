require 'test_helper'

describe OrderDetail::TransferDomain do
  describe :as_json do
    subject { order_detail.as_json }

    let(:order_detail) { build :transfer_domain_order_detail }

    let(:expected_json) {
      {
        type: 'transfer_domain',
        price: 15.00,
        domain: 'domain.ph',
        registrant_handle: 'contact',
        object: nil
      }
    }

    specify { subject.must_equal expected_json }
  end

  describe :complete! do
    subject { create :transfer_domain_order_detail }

    let(:domain) { create :domain }
    let(:saved_domain) { Domain.named(domain.full_name) }
    let(:latest_ledger_entry) { subject.order.partner.ledgers.last }

    before do
      domain

      subject.complete!
    end

    specify { subject.registrant_handle.wont_be_empty }
    specify { subject.complete?.must_equal true }
    specify { subject.product.must_equal saved_domain.product }

    specify { saved_domain.partner.must_equal subject.order.partner }

    specify { latest_ledger_entry.activity_type.must_equal 'use' }
    specify { latest_ledger_entry.amount.must_equal -15.00.money }
  end

  describe :build do
    subject { OrderDetail::TransferDomain.build params, nil }

    let(:params) {
      {
      }
    }

    specify { subject.period.must_equal 0 }
  end
end
