require 'spec_helper'

RSpec.describe SponsorPresenter do
  let(:sponsor_presenter) { SponsorPresenter.new(sponsor) }
  let(:sponsor) { Fabricate(:sponsor, contacts: contacts) }
  let(:contact) { Fabricate(:contact) }
  let(:contacts) { [contact] }

  context '#decorate_collection' do
    it 'decorates a collection of Sponsors' do
      expect(SponsorPresenter).to receive(:new).with(sponsor)

      SponsorPresenter.decorate_collection([sponsor])
    end
  end

  context '#address' do
    it 'should decorate the sponsor address' do
      expect(AddressPresenter).to receive(:new).with(sponsor.address)

      sponsor_presenter.address
    end
  end

  context '#contacts' do
    it 'should decorate the sponsor contacts' do
      expect(ContactPresenter).to receive(:decorate_collection).with(contacts)

      sponsor_presenter.contacts
    end
  end

  context '#sponsorships_count' do
    before(:each) do
      Fabricate(:workshop_sponsor, sponsor: sponsor)
      Fabricate.times(2, :sponsorship, sponsor: sponsor)
    end

    it 'returns the total number of event sponsorships associated with the sponsor' do
      expect(sponsor_presenter.sponsorships_count).to eq(3)
    end
  end
end
