require 'test_helper'

describe OrderDetail::TransferDomain do
  describe :as_json do
    subject { order_detail.as_json }

    let(:order_detail) { build :transfer_domain_order_detail }

    let(:expected_json) {
      {
        type: 'domain_transfer',
        price: 15.00,
        domain: 'domain.ph'
      }
    }

    specify { subject.must_equal expected_json }
  end

  describe :complete! do
    subject { create :transfer_domain_order_detail }

    let(:domain) { create :domain }
    let(:saved_domain) { Domain.named(domain.full_name) }
    let(:latest_ledger_entry) { subject.order.partner.credits.last }

    before do
      domain

      subject.complete!
    end

    specify { subject.complete?.must_equal true }
    specify { subject.product.must_equal saved_domain.product }

    specify { saved_domain.partner.must_equal subject.order.partner }

    specify { latest_ledger_entry.activity_type.must_equal 'use' }
    specify { latest_ledger_entry.credits.must_equal BigDecimal.new(-15) }
  end
end
