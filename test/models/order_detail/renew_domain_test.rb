require 'test_helper'

describe OrderDetail::RenewDomain do
  describe :complete! do
    subject { create :renew_domain_order_detail }

    before do
      create :domain, partner: subject.order.partner

      subject.complete!
    end

    let(:saved_domain) { Domain.named(subject.domain) }
    let(:latest_ledger_entry) { subject.order.partner.credits.last }

    specify { subject.complete?.must_equal true }
    specify { saved_domain.expires_at.must_equal '2016-01-01 00:00'.in_time_zone }
    specify { subject.product.must_equal saved_domain.product }

    specify { latest_ledger_entry.activity_type.must_equal 'use' }
    specify { latest_ledger_entry.credits.must_equal -35.money }
  end

  describe :execute do
    subject { OrderDetail::RenewDomain.execute domain: domain, period: period }

    before do
      subject
    end

    let(:domain) { create :domain }
    let(:period) { 2 }

    let(:saved_domain) { Domain.named(domain.full_name) }

    specify { OrderDetail.last.must_be_kind_of OrderDetail::RenewDomain }
    specify { OrderDetail.last.complete?.must_equal true }
    specify { OrderDetail.last.price.must_equal 64.00.money }
    specify { OrderDetail.last.domain.must_equal domain.full_name }
    specify { OrderDetail.last.period.must_equal period }

    specify { OrderDetail.last.order.total_price.must_equal 64.00.money }
    specify { OrderDetail.last.order.complete?.must_equal true }
    specify { OrderDetail.last.order.partner.must_equal domain.partner }

    specify { saved_domain.partner.credits.last.credits.must_equal BigDecimal.new(-64) }
    specify { saved_domain.partner.credits.last.activity_type.must_equal 'use' }

    specify { saved_domain.expires_at.must_equal '2017-01-01'.in_time_zone }
  end

  describe :reverse! do
    subject { create :renew_domain_order_detail }

    before do
      create :domain, partner: subject.order.partner

      subject.complete!
      subject.reverse!
    end

    let(:saved_domain) { Domain.named(subject.domain) }

    specify { saved_domain.expires_at.must_equal '2015-01-01'.in_time_zone }

    specify { ObjectActivity.last.must_be_kind_of ObjectActivity::Update }
    specify { ObjectActivity.last.property_changed.must_equal 'expires_at' }
    specify { ObjectActivity.last.old_value.must_equal '2016-01-01 00:00:00 UTC' }
    specify { ObjectActivity.last.value.must_equal '2015-01-01 00:00:00 UTC' }
  end
end
