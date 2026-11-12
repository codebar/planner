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

    context 'when the member is subscribed as both student and coach' do
      render_views

      let(:invitation) { Fabricate(:invitation, event:, role: 'Student') }

      before do
        member = invitation.member
        Fabricate(:subscription, member:, group: Fabricate(:group, name: 'Students'))
        Fabricate(:subscription, member:, group: Fabricate(:group, name: 'Coaches'))
      end

      it 'renders the role choice to a dual-role member who has not RSVPd' do
        get :show, params: { event_id: event.id, token: invitation.token }

        expect(response.body).to include('Choose how you would like to attend')
        expect(response.body).to include('RSVP as a student')
        expect(response.body).to include('RSVP as a coach')
      end

      it 'renders no role choice when the member already attends the event in another role' do
        Fabricate(:attending_event_invitation, event:, member: invitation.member, role: 'Coach')

        get :show, params: { event_id: event.id, token: invitation.token }

        expect(response.body).not_to include('Choose how you would like to attend')
        expect(response.body).to include("You have already RSVP'd to this event as a coach")
      end
    end

    context 'when the member is subscribed in a single role' do
      render_views

      let(:invitation) { Fabricate(:invitation, event:, role: 'Student') }

      it 'renders no role choice' do
        get :show, params: { event_id: event.id, token: invitation.token }

        expect(response.body).not_to include('Choose how you would like to attend')
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

    context 'when the member chooses a role' do
      let(:invitation) { Fabricate(:invitation, event:, role: 'Student') }

      before { Fabricate(:subscription, member: invitation.member, group: Fabricate(:group, name: 'Coaches')) }

      it 'accepts in the chosen role' do
        post :attend, params: { event_id: event.id, token: invitation.token, role: 'Coach' }

        expect(invitation.reload.role).to eq('Coach')
        expect(invitation.attending).to be true
      end

      it 'keeps the invitation role when the chosen role is full' do
        event.update!(coach_spaces: 0)

        post :attend, params: { event_id: event.id, token: invitation.token, role: 'Coach' }

        expect(invitation.reload.role).to eq('Student')
        expect(invitation.attending).not_to be true
      end

      it 'does not change the role of an invitation that is already accepted' do
        invitation.update!(attending: true)

        post :attend, params: { event_id: event.id, token: invitation.token, role: 'Coach' }

        expect(invitation.reload.role).to eq('Student')
      end

      it 'lets a cancelled member choose a role again' do
        invitation.update!(attending: true, verified: true, role: 'Student')
        invitation.update!(attending: false)

        post :attend, params: { event_id: event.id, token: invitation.token, role: 'Coach' }

        expect(invitation.reload.role).to eq('Coach')
        expect(invitation.attending).to be true
      end
    end

    context 'when the member is not subscribed to the chosen role' do
      let(:invitation) { Fabricate(:invitation, event:, role: 'Student') }

      it 'keeps the invitation role and accepts' do
        post :attend, params: { event_id: event.id, token: invitation.token, role: 'Coach' }

        expect(invitation.reload.role).to eq('Student')
        expect(invitation.attending).to be true
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
