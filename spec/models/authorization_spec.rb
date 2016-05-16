RSpec.describe Authorization do
  describe 'associations' do
    subject { FactoryGirl.create :authorization }

    it 'belongs to user' do
      expect(subject.user).not_to be nil
    end
  end
end
