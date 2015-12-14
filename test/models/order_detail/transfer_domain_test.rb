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
    let(:latest_ledger_entry) { subject.order.partner.credits.last }

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

  describe :execute do
    subject { OrderDetail.last }

    before do
      OrderDetail::TransferDomain.execute domain: domain.name,
                                          to: partner.name,
                                          at: transferred_at,
                                          handle: registrant.handle
    end

    let(:domain) { create :domain }
    let(:partner) { create :other_partner }
    let(:registrant) { create :other_contact }
    let(:transferred_at) { '2015-08-10 3:00 PM'.in_time_zone }

    specify { subject.must_be_kind_of OrderDetail::TransferDomain }
    specify { subject.complete?.must_equal true }
    specify { subject.price.must_equal 15.00.money }
    specify { subject.domain.must_equal domain.full_name }

    specify { subject.order.total_price.must_equal 15.00.money }
    specify { subject.order.complete?.must_equal true }
    specify { subject.order.partner.must_equal partner }
    specify { subject.order.ordered_at.must_equal transferred_at }

    specify { partner.credits.last.amount.must_equal -15.00.money }
    specify { partner.credits.last.activity_type.must_equal 'use' }

    specify { domain.domain_activities.last.activity_at.must_equal transferred_at }

    context :when_no_transfer_fee do
      before do
        OrderDetail::TransferDomain.execute domain: domain.name,
                                            to: partner.name,
                                            at: transferred_at,
                                            fee: false,
                                            handle: registrant.handle
      end
      
      let(:registrant) { create :other_contact }

      specify { subject.price.must_equal 0.00.money }
      specify { subject.order.total_price.must_equal 0.00.money }
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
