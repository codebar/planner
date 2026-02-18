RSpec.describe WorkshopSponsor do
  context 'validates' do
    it 'sponsor_id for uniqueness' do
      expect(subject).to validate_uniqueness_of(:sponsor_id)
        .scoped_to(:workshop_id)
        .with_message('already a sponsor')
    end
  end

  describe '#set_as_host!' do
    let(:workshop_sponsor) { Fabricate(:workshop_sponsor, host: false) }

    it 'sets host to true' do
      workshop_sponsor.set_as_host!
      expect(workshop_sponsor.reload.host).to be true
    end

    it 'raises RecordInvalid on validation failure' do
      allow(workshop_sponsor).to receive(:valid?).and_return(false)
      expect { workshop_sponsor.set_as_host! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#remove_as_host!' do
    let(:workshop_sponsor) { Fabricate(:workshop_sponsor, host: true) }

    it 'sets host to false' do
      workshop_sponsor.remove_as_host!
      expect(workshop_sponsor.reload.host).to be false
    end

    it 'raises RecordInvalid on validation failure' do
      allow(workshop_sponsor).to receive(:valid?).and_return(false)
      expect { workshop_sponsor.remove_as_host! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
