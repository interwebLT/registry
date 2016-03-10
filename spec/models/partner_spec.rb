RSpec.describe Partner do
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
end
