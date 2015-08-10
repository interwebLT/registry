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
        object: nil
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
    specify { latest_ledger_entry.amount.must_equal -15.00.money }
  end

  describe :execute do
    subject { OrderDetail::TransferDomain.execute domain: domain.name, to: partner.name, at: transferred_at }

    before do
      subject
    end

    let(:domain) { create :domain }
    let(:partner) { create :other_partner }
    let(:transferred_at) { '2015-08-10 3:00 PM'.in_time_zone }

    specify { OrderDetail.last.must_be_kind_of OrderDetail::TransferDomain }
    specify { OrderDetail.last.complete?.must_equal true }
    specify { OrderDetail.last.price.must_equal 15.00.money }
    specify { OrderDetail.last.domain.must_equal domain.full_name }

    specify { OrderDetail.last.order.total_price.must_equal 15.00.money }
    specify { OrderDetail.last.order.complete?.must_equal true }
    specify { OrderDetail.last.order.partner.must_equal partner }
    specify { OrderDetail.last.order.ordered_at.must_equal transferred_at }

    specify { partner.credits.last.amount.must_equal -15.00.money }
    specify { partner.credits.last.activity_type.must_equal 'use' }

    specify { domain.domain_activities.last.activity_at.must_equal transferred_at }

    context :when_no_transfer_fee do
      subject { OrderDetail::TransferDomain.execute domain: domain.name, to: partner.name, fee: false }

      specify { OrderDetail.last.price.must_equal 0.00.money }
      specify { OrderDetail.last.order.total_price.must_equal 0.00.money }
      specify { partner.credits.last.amount.must_equal 0.00.money }
    end
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
