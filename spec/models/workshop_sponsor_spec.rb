require 'spec_helper'

RSpec.describe WorkshopSponsor, type: :model do
  context 'validates' do
    it 'sponsor_id for uniqueness' do
      is_expected.to validate_uniqueness_of(:sponsor_id)
        .scoped_to(:workshop_id)
        .with_message('already a sponsor')
    end
  end

  context '#scopes' do
    context '#hosts' do
      it 'includes workshops with hosts' do
        workshop_sponsor = Fabricate(:workshop_sponsor, host: true)

        expect(WorkshopSponsor.hosts).to include(workshop_sponsor)
      end

      it 'excludes workshops without hosts' do
        expect(WorkshopSponsor.hosts).to eq []
      end
    end

    context '#for_workshop' do
      it 'includes sponsors of the workshop' do
        workshop_sponsor = Fabricate(:workshop_sponsor)
        expect(WorkshopSponsor.for_workshop(workshop_sponsor.workshop)).to include(workshop_sponsor)
      end

      it 'excludes sponsors not sponsoring the workshop' do
        Fabricate(:workshop_sponsor)
        workshop = Fabricate(:workshop_no_sponsor)
        expect(WorkshopSponsor.for_workshop(workshop)).to eq []
      end
    end
  end
end
