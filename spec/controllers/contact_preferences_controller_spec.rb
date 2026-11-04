require 'rails_helper'

RSpec.describe ContactPreferencesController do
  let(:contact) { Fabricate(:contact, mailing_list_consent: false) }

  before do
    allow(ContactMailingListService).to receive(:sync)
  end

  describe 'GET #show' do
    it 'sets the contact for a valid token' do
      get :show, params: { token: contact.token }

      expect(response).to have_http_status(:success)
      expect(controller.instance_variable_get(:@contact)).to eq(contact)
      expect(flash[:notice]).to be_nil
    end

    it 'shows an invalid-session notice for an unknown token' do
      get :show, params: { token: 'unknown-token' }

      expect(response).to have_http_status(:success)
      expect(flash[:notice]).to eq(I18n.t('messages.invalid_session'))
    end
  end

  describe 'PATCH #update' do
    it 'passes the contact and email to the activity recorder' do
      expect(MemberActivityRecorder).to receive(:record).with(
        actor: contact,
        key: 'sponsor.contact_subscribe',
        trackable: contact.sponsor,
        contact_email: contact.email
      )

      patch :update, params: {
        contact: { token: contact.token, mailing_list_consent: '1' }
      }
    end

    it 'subscribes the contact and records the consent activity' do
      patch :update, params: {
        contact: { token: contact.token, mailing_list_consent: '1' }
      }

      expect(contact.reload.mailing_list_consent).to be(true)
      expect(ContactMailingListService).to have_received(:sync).with(contact)
      expect(response).to redirect_to(
        contact_preferences_path(token: contact.token, notice: I18n.t('messages.contact_preferences.updated'))
      )

      activity = PublicActivity::Activity.find_by!(key: 'sponsor.contact_subscribe')
      expect(activity.owner).to eq(contact)
      expect(activity.trackable).to eq(contact.sponsor)
      expect(activity.parameters).to include(note: contact.email)
    end

    it 'unsubscribes the contact and records the consent activity' do
      contact.update!(mailing_list_consent: true)

      patch :update, params: {
        contact: { token: contact.token, mailing_list_consent: '0' }
      }

      expect(contact.reload.mailing_list_consent).to be(false)
      expect(ContactMailingListService).to have_received(:sync).with(contact)

      activity = PublicActivity::Activity.find_by!(key: 'sponsor.contact_unsubscribe')
      expect(activity.owner).to eq(contact)
      expect(activity.trackable).to eq(contact.sponsor)
      expect(activity.parameters).to include(note: contact.email)
    end

    it 'returns not found when the submitted token is unknown' do
      patch :update, params: {
        contact: { token: 'unknown-token', mailing_list_consent: '1' }
      }

      expect(response).to have_http_status(:not_found)
    end
  end
end
