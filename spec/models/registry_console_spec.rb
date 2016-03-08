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

    it 'logs activity on domain registration' do
      expect(ObjectActivity.last).not_to be nil
      expect(ObjectActivity.last).to be_an_instance_of ObjectActivity::Update
      expect(ObjectActivity.last.activity_at).to eql renewed_at
    end

    it 'deducts fee from partner' do
      expect(domain.partner.ledgers.last.amount).to eql -64.00.money
      expect(domain.partner.ledgers.last.activity_type).to eql 'use'
    end
  end
end
