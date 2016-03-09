RSpec.describe RegistryConsole do
  describe '.register_domain' do
    before do
      RegistryConsole.register_domain partner:  partner.name,
                                      domain: domain.name,
                                      authcode: domain.authcode,
                                      period: period,
                                      registrant_handle:  domain.registrant_handle,
                                      at: registered_at,
                                      skip_create: skip_create
    end

    let(:partner)       { FactoryGirl.create :partner }
    let(:domain)        { FactoryGirl.build :domain }
    let(:period)        { 2 }
    let(:registered_at) { domain.registered_at }
    let(:skip_create)   { false }

    it 'creates a completed order' do
      expect(Order.last).not_to be nil
      expect(Order.last.total_price).to eql 70.00.money
      expect(Order.last.ordered_at).to eql registered_at
      expect(Order.last).to be_complete

      expect(OrderDetail.last).not_to be nil
      expect(OrderDetail.last).to be_an_instance_of OrderDetail::RegisterDomain
      expect(OrderDetail.last.order).to eql Order.last
      expect(OrderDetail.last.price).to eql 70.00.money
      expect(OrderDetail.last.period).to eql period
      expect(OrderDetail.last.domain).to eql domain.name
      expect(OrderDetail.last.authcode).to eql domain.authcode
      expect(OrderDetail.last.registrant_handle).to eql domain.registrant_handle
      expect(OrderDetail.last).to be_complete
    end

    it 'registers inactive domain' do
      expect(Domain.last).not_to be nil
      expect(Domain.last.name).to eql domain.name
      expect(Domain.last.registrant_handle).to eql domain.registrant_handle
      expect(Domain.last.registered_at).to eql registered_at
      expect(Domain.last.expires_at).to eql (registered_at + period.years)

      expect(Domain.last).to be_inactive
    end

    it 'logs activity on domain registration' do
      expect(ObjectActivity.last).not_to be nil
      expect(ObjectActivity.last).to be_an_instance_of ObjectActivity::Create
      expect(ObjectActivity.last.activity_at).to eql registered_at
    end

    context 'when skip_create is enabled' do
      let(:skip_create) { true }

      it 'domain must not be created' do
        expect(Domain.exists?(name: domain.name)).to be false
      end

      specify 'order must be marked complete' do
        expect(Order.last).to be_complete
        expect(OrderDetail.last).to be_complete
      end
    end
  end

  describe '.renew_domain' do
    before do
      RegistryConsole.renew_domain  domain: domain.name,
                                    period: period,
                                    at: renewed_at
    end

    let(:domain)      { FactoryGirl.create :domain }
    let(:period)      { 2 }
    let(:renewed_at)  { '2015-05-08 8:00 PM'.in_time_zone }

    it 'creates a completed order' do
      expect(Order.last).not_to be nil
      expect(Order.last.total_price).to eql 64.00.money
      expect(Order.last.ordered_at).to eql renewed_at
      expect(Order.last).to be_complete

      expect(OrderDetail.last).not_to be nil
      expect(OrderDetail.last).to be_an_instance_of OrderDetail::RenewDomain
      expect(OrderDetail.last.order).to eql Order.last
      expect(OrderDetail.last.price).to eql 64.00.money
      expect(OrderDetail.last.period).to eql period
      expect(OrderDetail.last.domain).to eql domain.name
      expect(OrderDetail.last).to be_complete
    end

    it 'renews domain' do
      expect(Domain.named(domain.name).expires_at).to eql '2017-01-01'.in_time_zone
    end

    it 'logs activity on domain renewal' do
      expect(ObjectActivity.last).not_to be nil
      expect(ObjectActivity.last).to be_an_instance_of ObjectActivity::Update
      expect(ObjectActivity.last.activity_at).to eql renewed_at
    end

    it 'deducts fee from partner' do
      expect(domain.partner.ledgers.last.amount).to eql -64.00.money
      expect(domain.partner.ledgers.last.activity_type).to eql 'use'
    end
  end

  describe '.migrate_domain' do
    before do
      RegistryConsole.migrate_domain  partner: partner.name,
                                      domain: domain,
                                      registrant_handle: contact.handle,
                                      registered_at: registered_at,
                                      expires_at: expires_at,
                                      at: migrated_at
    end

    let(:partner)       { FactoryGirl.create :partner }
    let(:domain)        { 'test.ph' }
    let(:contact)       { FactoryGirl.create :contact }
    let(:registered_at) { '2015-05-11 5:30 PM'.in_time_zone }
    let(:expires_at)    { '2017-05-11 5:30 PM'.in_time_zone }
    let(:migrated_at)   { '2015-08-10 4:00 PM'.in_time_zone }

    it 'creates a completed order' do
      expect(Order.last).not_to be nil
      expect(Order.last.total_price).to eql 0.00.money
      expect(Order.last.ordered_at).to eql migrated_at
      expect(Order.last).to be_complete

      expect(OrderDetail.last).not_to be nil
      expect(OrderDetail.last).to be_an_instance_of OrderDetail::MigrateDomain
      expect(OrderDetail.last.order).to eql Order.last
      expect(OrderDetail.last.price).to eql 0.00.money
      expect(OrderDetail.last.domain).to eql domain
      expect(OrderDetail.last.authcode).to eql '1'
      expect(OrderDetail.last.registrant_handle).to eql contact.handle
      expect(OrderDetail.last.registered_at).to eql registered_at
      expect(OrderDetail.last.expires_at).to eql expires_at
      expect(OrderDetail.last).to be_complete
    end

    it 'migrates domain' do
      expect(Domain.last).not_to be nil
      expect(Domain.last.name).to eql domain
      expect(Domain.last.partner).to eql partner
      expect(Domain.last.registrant).to eql contact
      expect(Domain.last.registered_at).to eql registered_at
      expect(Domain.last.expires_at).to eql expires_at
    end

    it 'logs activity on migrate domain' do
      expect(ObjectActivity.last).not_to be nil
      expect(ObjectActivity.last).to be_an_instance_of ObjectActivity::Create
      expect(ObjectActivity.last.activity_at).to eql migrated_at
    end
  end

  describe '.transfer_domain' do
    before do
      RegistryConsole.transfer_domain domain: domain.name,
                                      to: partner.name,
                                      at: transferred_at,
                                      handle: registrant.handle,
                                      fee: fee
    end

    let(:domain)          { FactoryGirl.create :domain }
    let(:partner)         { FactoryGirl.create :other_partner }
    let(:registrant)      { FactoryGirl.create :other_contact }
    let(:transferred_at)  { '2015-08-10 3:00 PM'.in_time_zone }
    let(:fee)             { true }

    it 'creates a completed order' do
      expect(Order.last).not_to be nil
      expect(Order.last.partner).to eql partner
      expect(Order.last.total_price).to eql 15.00.money
      expect(Order.last.ordered_at).to eql transferred_at
      expect(Order.last).to be_complete

      expect(OrderDetail.last).not_to be nil
      expect(OrderDetail.last).to be_an_instance_of OrderDetail::TransferDomain
      expect(OrderDetail.last.order).to eql Order.last
      expect(OrderDetail.last.price).to eql 15.00.money
      expect(OrderDetail.last.domain).to eql domain.name
      expect(OrderDetail.last.registrant_handle).to eql registrant.handle
      expect(OrderDetail.last).to be_complete
    end

    it 'transfers domain' do
      expect(Domain.last.partner).to eql partner
    end

    it 'logs activity on transfer domain' do
      expect(ObjectActivity.last).not_to be nil
      expect(ObjectActivity.last).to be_an_instance_of ObjectActivity::Transfer
      expect(ObjectActivity.last.activity_at).to eql transferred_at
      expect(ObjectActivity.last.registrant_handle).to eql domain.registrant_handle
      expect(ObjectActivity.last.losing_partner).to eql domain.partner
    end

    it 'deducts fee from gaining partner' do
      expect(partner.ledgers.last.amount).to eql -15.00.money
      expect(partner.ledgers.last.activity_type).to eql 'use'
    end

    context 'when no transfer fee' do
      let(:fee) { false }

      it 'creates a completed order with zero price' do
        expect(Order.last).not_to be nil
        expect(Order.last.partner).to eql partner
        expect(Order.last.total_price).to eql 0.00.money
        expect(Order.last.ordered_at).to eql transferred_at
        expect(Order.last).to be_complete

        expect(OrderDetail.last).not_to be nil
        expect(OrderDetail.last).to be_an_instance_of OrderDetail::TransferDomain
        expect(OrderDetail.last.order).to eql Order.last
        expect(OrderDetail.last.price).to eql 0.00.money
        expect(OrderDetail.last.domain).to eql domain.name
        expect(OrderDetail.last.registrant_handle).to eql registrant.handle
        expect(OrderDetail.last).to be_complete
      end

      it 'does not deduct fee from gaining partner' do
        expect(partner.ledgers.last.amount).to eql 0.00.money
        expect(partner.ledgers.last.activity_type).to eql 'use'
      end
    end
  end
end
