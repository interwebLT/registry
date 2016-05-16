RSpec.describe Partner do
  describe 'associations' do
    subject { FactoryGirl.create :partner }

    before do
      contact = FactoryGirl.create :contact

      FactoryGirl.create :domain,           partner: subject, registrant: contact
      FactoryGirl.create :partner_pricing,  partner: subject
      FactoryGirl.create :ledger,           partner: subject
      FactoryGirl.create :host,             partner: subject
      FactoryGirl.create :authorization,    partner: subject
    end

    it 'has many domains' do
      expect(subject.domains.count).to eql 1
    end

    it 'has many ledgers' do
      expect(subject.ledgers.count).to eql 2
    end

    it 'has many partner_configurations' do
      expect(subject.partner_configurations.count).to eql 4
    end

    it 'has many partner_pricings' do
      expect(subject.partner_pricings.count).to eql 27
    end

    it 'has many hosts' do
      expect(subject.hosts.count).to eql 3
    end
  end

  describe '.named' do
    subject { Partner.named param }

    let(:partner) { FactoryGirl.create :partner }

    context 'when name provided' do
      let(:param) { partner.name }

      it { is_expected.to eql partner }
    end

    context 'when id provided' do
      let(:param) { partner.id }

      it { is_expected.to eql partner }
    end
  end

  describe '#password' do
    subject { Partner.new }

    it 'is encrypted upon being set' do
      expect(subject.encrypted_password).to be nil

      subject.password = 'password'

      expect(subject.encrypted_password).not_to be nil
      expect(subject.encrypted_password).not_to eql 'password'
    end

    it 'authenticates properly' do
      subject.password = 'password'

      expect(subject.password_matches('password')).to be true
      expect(subject.password_matches('wrong')).to be false
    end

    it 'changes salt when it is set' do
      salt = subject.salt

      subject.password = 'password'

      expect(subject.salt).not_to eql salt
    end
  end
end
