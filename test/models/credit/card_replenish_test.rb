require 'test_helper'

describe Credit::CardReplenish do
  describe :build do
    subject { Credit.build(params, partner) }

    let(:partner) { create :complete_partner }

    let(:params) {
      {
        type: 'card_credit',
        amount: 150.00,
        remarks: 'this is a remark'
      }
    }

    specify { subject.valid?.must_equal true }
    specify { subject.must_be_kind_of Credit::CardReplenish }
    specify { subject.amount.must_equal 150.00.money }
  end

  describe :complete! do
    subject { create :pending_replenish_credits }

    before do
      subject.complete!
    end

    let(:latest_ledger_entry) { subject.partner.ledgers.last }

    specify { subject.complete?.must_equal true }
    specify { latest_ledger_entry.amount.must_equal 150.00.money }
    specify { latest_ledger_entry.activity_type.must_equal 'topup' }
  end

  describe :execute do
    subject { Credit.last }

    before do
      Credit.execute  partner: partner.name,
                      credit: credits,
                      remarks: 'this is a remark',                                      
                      at: credited_at
    end

    let(:partner) { create :partner }
    let(:credits) { 123.45 }
    let(:credited_at) { '2015-08-10 4:30 PM'.in_time_zone }

    specify { subject.must_be_kind_of Credit }
    specify { subject.complete?.must_equal true }
    specify { subject.amount.must_equal credits.money }

    specify { partner.ledgers.last.amount.must_equal credits.money }
    specify { partner.ledgers.last.activity_type.must_equal 'topup' }
  end
end