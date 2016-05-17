RSpec.describe ExternalRegistry do
  subject { ExternalRegistry.new name: name, url: url }

  let(:name)  { 'registry' }
  let(:url)   { 'http://localhost:9000' }

  describe '#valid?' do
    it { is_expected.to be_valid }

    context 'when name is nil' do
      let(:name) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when url is nil' do
      let(:url) { nil }

      it { is_expected.not_to be_valid }
    end

    context 'when name is not unique' do
      before do
        FactoryGirl.create :external_registry
      end

      it { is_expected.not_to be_valid }
    end
  end
end
