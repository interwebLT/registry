RSpec.describe MigratedDomain do
  subject(:migrated_domain) do
    MigratedDomain.new  name:               name,
                        partner:            partner,
                        registrant_handle:  registrant_handle,
                        registered_at:      registered_at,
                        expires_at:         expires_at,
                        authcode:           authcode
  end

  let(:name)              { 'test.ph' }
  let(:partner)           { FactoryGirl.create :partner }
  let(:registrant_handle) { registrant.handle }
  let(:registered_at)     { '2016-06-07 10:00:00 AM'.in_time_zone }
  let(:expires_at)        { '2016-06-07 10:00:00 AM'.in_time_zone }
  let(:authcode)          { '123456789ABCDEF' }

  let(:registrant)        { FactoryGirl.create :registrant }

  describe 'associations' do
    before do
      subject.save
    end

    it 'belongs to partner' do
      expect(subject.partner).to eq partner
    end
  end

  describe '#save' do
    context 'when domain not yet migrated' do
      before do
        subject.save
      end

      it { is_expected.to be_persisted }

      it 'migrates domain on save' do
        expect(Domain.last).to have_attributes  name:               name,
                                                partner:            partner,
                                                registrant_handle:  registrant_handle,
                                                registered_at:      registered_at,
                                                expires_at:         expires_at,
                                                authcode:           authcode
      end
    end

    context 'when domain already exists' do
      before do
        FactoryGirl.create :domain, name:       name,
                                    registrant: registrant

        subject.save
      end

      it { is_expected.to be_persisted }
    end
  end
end
