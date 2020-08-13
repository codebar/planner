require 'spec_helper'

RSpec.describe SponsorPresenter do
  let(:sponsor_presenter) { SponsorPresenter.new(sponsor) }
  let(:sponsor) { double(:sponsor, contacts: contacts, members: []) }
  let(:contact) { Fabricate(:contact, name: 'Jean', surname: 'Doe', email: 'jean@doe.com') }
  let(:contacts) { [contact] }
  let(:member_contact_details) { ['<li>Jean Doe (<a href="mailto:jean@doe.com">jean@doe.com</a>) <i class="fa fa-bell"></i></li>'] }

  context '#contact_info' do
    it 'should correctly format both member and contact details' do
      expect(sponsor_presenter.contact_info).to eq(member_contact_details.join)
    end
  end

  context '#member_contact_details' do
    it 'should correctly format the contacts details' do
      expect(sponsor_presenter.contacts_details).to eq(member_contact_details)
    end
  end
end
