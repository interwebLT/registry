require 'test_helper'

describe Partner do
  describe :associations do
    subject { create :partner }

    before do
      contact = create :contact

      create :domain, partner: subject, registrant: contact
      create :partner_pricing, partner: subject
      create :ledger, partner: subject
      create :host, partner: subject
    end

    specify { subject.domains.wont_be_empty }
    specify { subject.ledgers.wont_be_empty }
    specify { subject.partner_configurations.wont_be_empty }
    specify { subject.partner_pricings.wont_be_empty }
    specify { subject.hosts.wont_be_empty }
  end

  describe :current_balance do
    subject { create :partner }

    context :when_partner_has_credits do
      before do
        create :ledger, partner: subject
        create :ledger, partner: subject
      end

      specify { subject.current_balance.must_equal 2000.00.money }
    end

    context :when_partner_has_no_credits do
      specify { subject.current_balance.must_equal 0.00.money }
    end
  end

  describe :pricing do
    subject { partner.pricing action: action, period: 2 }

    let(:partner) { create :complete_partner }

    context :when_pricing_present do
      let(:action) { 'domain_create' }

      specify { subject.must_equal 70.00.money }
    end

    context :when_pricing_not_present do
      let(:action) { 'not_existing' }

      specify { subject.must_equal 0.00.money }
    end
  end

  describe :register_domain do
    subject do
      partner.register_domain domain_name,
                              authcode: 'ABC123',
                              period: 2,
                              registrant_handle: registrant_handle,
                              registered_at: registered_at
    end

    let(:partner) { create :complete_partner }
    let(:registrant) { create :registrant }

    let(:domain_name) { 'test.ph' }
    let(:registrant_handle) { registrant.handle }
    let(:registered_at) { Time.now }

    context :when_successful do
      specify { subject.wont_be_nil }
      specify { subject.valid?.must_equal true }
      specify { subject.full_name.must_equal 'test.ph' }
      specify { subject.partner.must_equal partner }
      specify { subject.registered_at.must_equal registered_at }
      specify { subject.expires_at.must_equal (registered_at + 2.years) }
      specify { subject.authcode.must_equal 'ABC123' }
      specify { subject.registrant_handle.must_equal registrant_handle }
      specify { subject.product.wont_be_nil }
    end

    context :when_registrant_does_not_exist do
      let(:registrant_handle) { 'dne' }

      specify { subject.wont_be_nil }
      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
    end

    context :when_domain_with_two_level_tld do
      let(:domain_name) { 'test.com.ph' }

      specify { subject.wont_be_nil }
      specify { subject.full_name.must_equal domain_name }
    end
  end

  describe :renew_domain do
    subject { partner.renew_domain domain_name: 'domain.ph', period: 2 }

    before do
      create :domain, partner: partner
    end

    let(:partner) { create :complete_partner }

    specify { subject.expires_at.must_equal '2017-01-01 00:00'.in_time_zone }
  end

  describe :default_nameservers do
    subject { create :partner }

    context :when_partner_has_default_nameservers do
      specify { subject.default_nameservers.wont_be_empty }
      specify { subject.default_nameservers.must_equal ['ns3.domains.ph', 'ns4.domains.ph'] }
    end

    context :when_partner_has_no_default_nameservers do
      before do
        subject.partner_configurations.map(&:delete)
      end

      specify { subject.default_nameservers.must_be_empty }
    end
  end

  describe :credit_history do
    subject { create :partner }

    before do
      create :register_domain_order,    partner: subject
      create :refund_order,             partner: subject
    end

    specify { subject.credit_history.count.must_equal 0 }
  end

  describe :order_history do
    subject { create :partner }

    before do
      create :pending_register_domain_order,  partner: subject
      create :register_domain_order,          partner: subject
      create :renew_domain_order,             partner: subject
      create :transfer_domain_order,          partner: subject
      create :refund_order,                   partner: subject
    end

    specify { subject.order_history.count.must_equal 5 }
  end
end
