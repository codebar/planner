RSpec.describe WorkshopSponsor do
  context 'validates' do
    it 'sponsor_id for uniqueness' do
      is_expected.to validate_uniqueness_of(:sponsor_id)
        .scoped_to(:workshop_id)
        .with_message('already a sponsor')
    end
  end
end
