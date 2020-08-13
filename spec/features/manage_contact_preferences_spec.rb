require 'spec_helper'

RSpec.feature 'Managing contact preferences', type: :feature do

  context 'A sponsor contact can manage their contact preferences' do
    context 'they can subscribe' do
      let!(:contact) { Fabricate(:contact, mailing_list_consent: false) }

      scenario 'when they are not subscribed to the Sponsors mailing list' do
        visit contact_preferences_url(token: contact.token)
        check 'Sponsors mailing list'

        click_on 'Update'
        expect(page).to have_checked_field('contact_mailing_list_consent')
      end
    end

    context 'they can unsubscribe' do
      let!(:contact) { Fabricate(:contact) }

      scenario 'when they are subscribed to the Sponsors mailing list' do
        visit contact_preferences_url(token: contact.token)
        uncheck 'Sponsors mailing list'

        click_on 'Update'
        expect(page).to_not have_checked_field(:contact_mailing_list_consent)
      end
    end
  end
end
