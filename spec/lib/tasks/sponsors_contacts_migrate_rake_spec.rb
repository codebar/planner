require 'spec_helper'

RSpec.describe 'rake sponsors:contacts:migrate', type: :task do
  context 'moves sponsor contact information from Sponsor to Contact' do
    it "preloads the Rails environment" do
      expect(task.prerequisites).to include "environment"
    end

    it 'executes gracefully' do
      expect { task.invoke }.to_not raise_error
    end

    context 'when Sponsor has contact details' do
      let!(:sponsor) { Fabricate(:sponsor) }

      it 'creates a Contact associated with the Sponsor' do
        contact_email = sponsor.email
        contact_name = sponsor.contact_first_name
        contact_surname = sponsor.contact_surname

        task.execute

        contact = sponsor.contacts.first
        expect(contact.email).to eq(contact_email)
        expect(contact.name).to eq(contact_name)
        expect(contact.surname).to eq(contact_surname)
      end

      it 'removes the contact details' do
        task.execute

        sponsor.reload

        expect(sponsor.email).to eq(nil)
        expect(sponsor.contact_first_name).to eq(nil)
        expect(sponsor.contact_surname).to eq(nil)
      end
    end

    context 'when Sponsor does not have contact details' do
      let!(:sponsor) { Fabricate(:sponsor_no_contact_details) }

      it 'does nothing' do
        task.execute

        sponsor.reload
        expect(sponsor.contacts).to be_empty
      end
    end
  end
end
