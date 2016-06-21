RSpec.describe Host do
  subject(:host) do
    Host.new  partner:  partner,
              name:     name
  end

  let(:partner) { FactoryGirl.create :partner }
  let(:name)    { 'ns5.domains.ph' }

  describe '#valid?' do
    it { is_expected.to be_valid }

    context 'when partner is nil' do
      let(:partner) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when name is nil' do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when name is not unique' do
      before do
        FactoryGirl.create :host
      end

      it { is_expected.not_to be_valid }
    end
  end
end
