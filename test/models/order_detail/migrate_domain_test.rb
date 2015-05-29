require 'test_helper'

describe OrderDetail::MigrateDomain do
  describe :as_json do
    subject { build :migrate_domain_order_detail }

    let(:expected_json) {
      {
        type: 'migrate_domain',
        price:  0.00,
        domain: 'domain.ph',
        authcode: 'ABC123',
        registrant_handle:  'domains_r',
        registered_at:  '2015-04-10T11:00:00Z',
        expires_at: '2017-04-10T11:00:00Z'
      }
    }

    specify { subject.as_json.must_equal expected_json }
  end

  describe :complete! do
    subject { create :migrate_domain_order_detail }

    before do
      create :contact, handle: subject.registrant_handle

      subject.complete!
    end

    let(:saved_domain) { Domain.named(subject.domain) }
    let(:latest_ledger_entry) { subject.order.partner.credits.last }

    context :when_successful do
      specify { subject.complete?.must_equal true }
      specify { subject.product.must_equal saved_domain.product }

      specify { saved_domain.full_name.must_equal subject.domain }
      specify { saved_domain.authcode.must_equal subject.authcode }
      specify { saved_domain.registered_at.must_equal subject.registered_at }
      specify { saved_domain.expires_at.must_equal subject.expires_at }

      specify { latest_ledger_entry.activity_type.must_equal 'use' }
      specify { latest_ledger_entry.credits.must_equal 0.00 }
    end
  end

  describe :valid? do
    subject { build :migrate_domain_order_detail }

    context :when_valid do
      specify { subject.valid?.must_equal true }
    end

    context :when_no_domain do
      before do
        subject.domain = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:domain].must_equal ['invalid'] }
    end

    context :when_no_registrant_handle do
      before do
        subject.registrant_handle = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
    end

    context :when_no_registered_at do
      before do
        subject.registered_at = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registered_at].must_equal ['invalid'] }
    end

    context :when_no_expires_at do
      before do
        subject.expires_at = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:expires_at].must_equal ['invalid'] }
    end

    context :when_expires_at_before_registered_at do
      before do
        subject.expires_at    = '2000-01-01T00:00:00Z'
        subject.registered_at = '2015-01-01T00:00:00Z'

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:expires_at].must_equal ['invalid'] }
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

  describe :execute do
    subject { OrderDetail.last }

    before do
      OrderDetail::MigrateDomain.execute  partner: partner.name,
                                          domain: domain,
                                          registrant_handle: contact.handle,
                                          registered_at: registered_at,
                                          expires_at: expires_at
    end

    let(:partner) { create :partner }
    let(:domain)  { 'test.ph' }
    let(:contact) { create :contact }
    let(:registered_at) { '2015-05-11 5:30 PM'.in_time_zone }
    let(:expires_at)    { '2017-05-11 5:30 PM'.in_time_zone }

    let(:saved_domain) { Domain.named(domain) }

    specify { subject.must_be_kind_of OrderDetail::MigrateDomain }
    specify { subject.complete?.must_equal true }
    specify { subject.price.must_equal 0.00.money }
    specify { subject.domain.must_equal domain }
    specify { subject.authcode.wont_be_nil }
    specify { subject.registrant_handle.must_equal contact.handle }
    specify { subject.registered_at.must_equal registered_at }
    specify { subject.expires_at.must_equal expires_at }
  end
end
