require 'test_helper'

describe OrderDetail::RenewDomain do
  describe :aliases do
    subject { create :renew_domain_order_detail }

    specify { subject.current_expires_at.must_equal subject.expires_at }
  end

  describe :complete! do
    subject { create :renew_domain_order_detail }

    before do
      domain

      subject.complete!
    end

    let(:domain) { create :domain, partner: subject.order.partner }
    let(:saved_domain) { Domain.named(subject.domain) }
    let(:latest_ledger_entry) { subject.order.partner.ledgers.last }

    specify { saved_domain.expires_at.must_equal '2016-01-01 00:00'.in_time_zone }

    specify { subject.complete?.must_equal true }
    specify { subject.current_expires_at.must_equal domain.expires_at }
    specify { subject.product.must_equal saved_domain.product }

    specify { latest_ledger_entry.activity_type.must_equal 'use' }
    specify { latest_ledger_entry.amount.must_equal -35.00.money }
  end

  describe :execute do
    subject { OrderDetail.last }

    before do
      OrderDetail::RenewDomain.execute  domain: domain.name,
                                        period: period,
                                        at: renewed_at
    end

    let(:domain) { create :domain }
    let(:period) { 2 }
    let(:renewed_at) { '2015-05-08 8:00 PM'.in_time_zone }

    specify { subject.must_be_kind_of OrderDetail::RenewDomain }
    specify { subject.complete?.must_equal true }
    specify { subject.price.must_equal 64.00.money }
    specify { subject.domain.must_equal domain.full_name }
    specify { subject.period.must_equal period }

    specify { subject.order.total_price.must_equal 64.00.money }
    specify { subject.order.complete?.must_equal true }
    specify { subject.order.partner.must_equal domain.partner }
    specify { subject.order.ordered_at.must_equal renewed_at }

    specify { domain.partner.ledgers.last.amount.must_equal -64.00.money }
    specify { domain.partner.ledgers.last.activity_type.must_equal 'use' }
    specify { Domain.named(domain.name).expires_at.must_equal '2017-01-01'.in_time_zone }
    specify { domain.domain_activities.last.activity_at.must_equal renewed_at }
  end

  describe :reverse! do
    subject { create :renew_domain_order_detail }

    before do
      create :domain, partner: subject.order.partner

      subject.complete!
      subject.reverse!
    end

    specify { subject.reversed?.must_equal true }

    specify { Domain.named(subject.domain).expires_at.must_equal '2015-01-01'.in_time_zone }

    specify { ObjectActivity.last.must_be_kind_of ObjectActivity::Update }
    specify { ObjectActivity.last.property_changed.must_equal 'expires_at' }
    specify { ObjectActivity.last.old_value.must_equal '2016-01-01 00:00:00 UTC' }
    specify { ObjectActivity.last.value.must_equal '2015-01-01 00:00:00 UTC' }

    specify { Order.last.partner.ledgers.last.amount.must_equal 35.00.money }
  end

  describe :as_json do
    subject { build :renew_domain_order_detail }

    let(:expected_json) {
      {
        type: 'domain_renew',
        price:  35.00,
        domain: 'domain.ph',
        object: nil,
        period: 1
      }
    }

    specify { subject.as_json.must_equal expected_json }
  end

  describe :as_json_request do
    subject { create :renew_domain_order_detail }

    let(:expected_json) {
      {
        currency_code:  'USD',
        ordered_at: '2015-02-27 14:30'.in_time_zone,
        order_details: [
          {
            type: 'domain_renew',
            domain: 'domain.ph',
            period: 1,
            current_expires_at: nil
          }
        ]
      }
    }

    specify { subject.as_json_request.must_equal expected_json }
  end
end
