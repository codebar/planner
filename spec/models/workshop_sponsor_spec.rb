RSpec.describe WorkshopSponsor do
  subject(:workshop_sponsor) { Fabricate.build(:workshop_sponsor) }

  context 'validates' do
    it 'sponsor_id for uniqueness' do
      expect(workshop_sponsor).to validate_uniqueness_of(:sponsor_id)
        .scoped_to(:workshop_id)
        .with_message('already a sponsor')
    end
  end
end
