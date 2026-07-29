RSpec.describe Contact do
  subject(:contact) { Fabricate.build(:contact) }

  context 'with validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:surname) }
    it { is_expected.to validate_presence_of(:email) }

    it do
      Fabricate(:contact)
      expect(contact).to validate_uniqueness_of(:email).scoped_to(:sponsor_id)
    end
  end
end
