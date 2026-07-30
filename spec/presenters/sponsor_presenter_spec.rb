RSpec.describe SponsorPresenter do
  let(:sponsor_presenter) { described_class.new(sponsor) }
  let(:sponsor) { Fabricate(:sponsor, contacts: contacts) }
  let(:contact) { Fabricate(:contact) }
  let(:contacts) { [contact] }

  describe '#decorate_collection' do
    it 'decorates a collection of Sponsors' do
      allow(described_class).to receive(:new).with(sponsor)

      described_class.decorate_collection([sponsor])

      expect(described_class).to have_received(:new).with(sponsor)
    end
  end

  describe '#address' do
    it 'decorates the sponsor address' do
      allow(AddressPresenter).to receive(:new).with(sponsor.address)

      sponsor_presenter.address

      expect(AddressPresenter).to have_received(:new).with(sponsor.address)
    end
  end

  describe '#contacts' do
    it 'decorates the sponsor contacts' do
      allow(ContactPresenter).to receive(:decorate_collection).with(contacts)

      sponsor_presenter.contacts

      expect(ContactPresenter).to have_received(:decorate_collection).with(contacts)
    end
  end

  describe '#sponsorships_count' do
    before do
      Fabricate(:workshop_sponsor, sponsor: sponsor)
      Fabricate.times(2, :sponsorship, sponsor: sponsor)
    end

    it 'returns the total number of event sponsorships associated with the sponsor' do
      expect(sponsor_presenter.sponsorships_count).to eq(3)
    end
  end
end
