RSpec.describe EventsController do
  describe '#fetch_upcoming_events' do
    context 'when no events exist' do
      it 'returns empty hash and nil pagy' do
        expect(controller.send(:fetch_upcoming_events)).to eq([{}, nil])
      end
    end
  end

  describe '#fetch_past_events' do
    context 'when no events exist' do
      it 'returns empty hash and nil pagy' do
        expect(controller.send(:fetch_past_events)).to eq([{}, nil])
      end
    end
  end

  describe 'GET #student' do
    let(:member) { Fabricate(:member) }
    let(:event) { Fabricate(:event) }

    before { login(member) }

    context 'when the member already has an invitation for the event and role with attending nil' do
      let!(:invitation) do
        Fabricate(:invitation, event:, member:, role: 'Student', attending: nil)
      end

      it 'redirects to the existing invitation page' do
        get :student, params: { event_id: event.slug }

        expect(response).to redirect_to(event_invitation_path(event, invitation))
      end

      it 'does not create a new invitation' do
        expect do
          get :student, params: { event_id: event.slug }
        end.not_to change(Invitation, :count)
      end
    end

    context 'when the member does not have an invitation for the event and role' do
      it 'creates a new invitation and redirects' do
        expect do
          get :student, params: { event_id: event.slug }
        end.to change(Invitation, :count).by(1)

        invitation = Invitation.last
        expect(response).to redirect_to(event_invitation_path(event, invitation))
      end
    end
  end

  describe 'GET #coach' do
    let(:member) { Fabricate(:member) }
    let(:event) { Fabricate(:event) }

    before { login(member) }

    context 'when the member already has a coach invitation for the event with attending nil' do
      let!(:invitation) do
        Fabricate(:coach_invitation, event:, member:, attending: nil)
      end

      it 'redirects to the existing invitation page' do
        get :coach, params: { event_id: event.slug }

        expect(response).to redirect_to(event_invitation_path(event, invitation))
      end

      it 'does not create a new invitation' do
        expect do
          get :coach, params: { event_id: event.slug }
        end.not_to change(Invitation, :count)
      end
    end

    context 'when the member does not have a coach invitation for the event' do
      it 'creates a new coach invitation and redirects' do
        expect do
          get :coach, params: { event_id: event.slug }
        end.to change(Invitation, :count).by(1)

        invitation = Invitation.last
        expect(response).to redirect_to(event_invitation_path(event, invitation))
      end
    end
  end

  describe '#past' do
    before { Fabricate(:event, date_and_time: 2.weeks.ago) }

    context 'when the page param is invalid' do
      it 'clamps page 0 to page 1' do
        get :past, params: { page: 0 }
        expect(response).to have_http_status(:ok)
      end

      it 'handles SQL injection probes' do
        get :past, params: { page: "' OR '1'='1" }
        expect(response).to have_http_status(:ok)
      end

      it 'handles empty page params' do
        get :past, params: { page: '' }
        expect(response).to have_http_status(:ok)
      end

      it 'handles negative pages' do
        get :past, params: { page: -3 }
        expect(response).to have_http_status(:ok)
      end

      it 'handles array params' do
        get :past, params: { page: ['1'] }
        expect(response).to have_http_status(:ok)
      end
    end

    it 'renders the requested page' do
      get :past, params: { page: 1 }
      expect(response).to have_http_status(:ok)
    end
  end
end
