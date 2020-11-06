require 'spec_helper'

RSpec.feature 'Managing contact preferences', type: :feature do

  context 'A sponsor contact can manage their contact preferences' do
    let(:manager) { Fabricate(:member) }

    context 'they can subscribe' do
      let!(:contact) { Fabricate(:contact, mailing_list_consent: false) }

      scenario 'when they are not subscribed to the Sponsors mailing list' do
        visit contact_preferences_url(token: contact.token)
        check 'Sponsors mailing list'
        click_on 'Update'

        login_as_admin(manager)
        visit admin_sponsor_path(contact.sponsor)

        expect(page).to have_content("#{contact.name} #{contact.surname} with email #{contact.email} subscribed to the Sponsor newsletter")
      end
    end

    context 'they can unsubscribe' do
      let!(:contact) { Fabricate(:contact) }

      scenario 'when they are subscribed to the Sponsors mailing list' do
        visit contact_preferences_url(token: contact.token)
        uncheck 'Sponsors mailing list'
        click_on 'Update'

        login_as_admin(manager)
        visit admin_sponsor_path(contact.sponsor)

        expect(page).to have_content("#{contact.name} #{contact.surname} with email #{contact.email} unsubscribed from the Sponsor newsletter")
      end
    end
  end
end
