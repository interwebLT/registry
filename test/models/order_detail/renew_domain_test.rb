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
end
