require 'rails_helper'

RSpec.describe InvitationsController do
  let(:event) { Fabricate(:event) }

  describe 'GET #show' do
    context 'with invalid token' do
      it 'returns http not found' do
        get :show, params: { event_id: event.id, token: 'invalid_token' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #attend' do
    context 'with invalid token' do
      it 'returns http not found' do
        post :attend, params: { event_id: event.id, token: 'invalid_token' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when RSVPs have closed' do
      let(:event) { Fabricate(:event, date_and_time: 3.hours.from_now) }
      let(:invitation) { Fabricate(:invitation, event:) }

      it 'does not accept the RSVP' do
        post :attend, params: { event_id: event.id, token: invitation.token }

        expect(invitation.reload.attending).to be false
      end

      it 'redirects with a closed notice' do
        post :attend, params: { event_id: event.id, token: invitation.token }

        expect(flash[:notice]).to eq(I18n.t('messages.invitations.rsvps_closed'))
      end
    end

    context 'without a CSRF token (browser did not send session cookie)' do
      # Simulate the real-world scenario where the browser withholds the
      # session cookie (e.g. Safari/WebKit ITP on cross-site navigation).
      # The invitation token in the URL is the authenticator.
      include_context 'with forgery protection enforced'
      let(:invitation) { Fabricate(:coach_invitation, event:) }

      it 'still accepts the RSVP' do
        post :attend, params: { event_id: event.id, token: invitation.token }

        expect(invitation.reload.attending).to be true
      end
    end
  end

  describe 'POST #reject' do
    context 'with invalid token' do
      it 'returns http not found' do
        post :reject, params: { event_id: event.id, token: 'invalid_token' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without a CSRF token (browser did not send session cookie)' do
      include_context 'with forgery protection enforced'
      let(:invitation) { Fabricate(:attending_event_invitation, event:) }

      it 'still cancels the RSVP' do
        post :reject, params: { event_id: event.id, token: invitation.token }

        expect(invitation.reload.attending).to be false
      end
    end
  end

  describe 'GET #rsvp_meeting' do
    let(:meeting) { Fabricate(:meeting) }
    let(:invitation) { Fabricate(:meeting_invitation, meeting:) }

    before { login(invitation.member) }

    it 'accepts the RSVP when RSVPs are open' do
      get :rsvp_meeting, params: { meeting_id: meeting.id, token: invitation.token }

      expect(invitation.reload.attending).to be true
    end

    context 'when RSVPs have closed' do
      let(:meeting) { Fabricate(:meeting, date_and_time: 3.hours.from_now) }

      it 'does not accept the RSVP' do
        get :rsvp_meeting, params: { meeting_id: meeting.id, token: invitation.token }

        expect(invitation.reload.attending).to be false
      end

      it 'redirects with a closed notice' do
        get :rsvp_meeting, params: { meeting_id: meeting.id, token: invitation.token }

        expect(flash[:notice]).to eq(I18n.t('messages.invitations.rsvps_closed'))
      end
    end
  end
end
