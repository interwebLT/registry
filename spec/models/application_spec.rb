RSpec.describe Application do
  subject do
    Application.new partner:  partner,
                    token:    token,
                    client:   client
  end

  let(:partner) { FactoryGirl.create :partner }
  let(:token)   { '1234567890ABCDEF' }
  let(:client)  { 'client' }

  describe 'associations' do
    subject { FactoryGirl.create :application }

    it 'belongs to partner' do
      expect(subject.partner).not_to be nil
    end
  end

  describe '#valid?' do
    it { is_expected.to be_valid }

    context 'when partner is nil' do
      let(:partner) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when token is nil' do
      before do
        subject.token = nil
      end

      it { is_expected.not_to be_valid }
    end

    context 'when token is not unique' do
      before do
        FactoryGirl.create :application
      end

      it { is_expected.not_to be_valid }
    end

    context 'when client is nil' do
      let(:client) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#token' do
    context 'when token is nil' do
      let(:token) { nil }

      it 'generates token' do
        expect(subject.save).to be true
        expect(subject.token).not_to be nil
      end
    end
  end
end
