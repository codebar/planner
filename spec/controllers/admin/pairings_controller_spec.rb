require 'rails_helper'

RSpec.describe Admin::PairingsController do
  render_views

  let(:organiser) { Fabricate(:member) }
  let(:event) { Fabricate(:event, confirmation_required: true) }
  let(:student) { Fabricate(:invitation, event:, attending: true, verified: true) }
  let(:coach) { Fabricate(:coach_invitation, event:, attending: true, verified: true) }
  let(:second_student) { Fabricate(:invitation, event:, attending: true, verified: true) }

  before do
    organiser.add_role(:organiser, event)
    login(organiser)
    student
    coach
    second_student
  end

  describe 'GET #index' do
    it 'renders the dedicated pairings view for HTML requests' do
      get :index, params: { event_id: event.slug }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('pairing-board')
    end

    it 'returns 304 Not Modified on matching ETag for XHR live sync' do
      get :index, params: { event_id: event.slug }, xhr: true
      expect(response).to have_http_status(:ok)
      etag = response.headers['ETag']

      request.headers['If-None-Match'] = etag
      get :index, params: { event_id: event.slug }, xhr: true
      expect(response).to have_http_status(:not_modified)
    end
  end

  describe 'POST #create' do
    it 'moves the invitation into the target pairing and redirects on HTML requests' do
      target = event.pairings.ordered.first

      post :create, params: { event_id: event.slug, invitation_id: second_student.id, pairing_id: target.id }

      expect(response).to redirect_to(admin_event_path(event))
      expect(target.reload.invitations).to contain_exactly(student, coach, second_student)
    end

    it 'returns the rendered pairing board partial on XHR requests' do
      target = event.pairings.ordered.first

      post :create, params: { event_id: event.slug, invitation_id: second_student.id, pairing_id: target.id }, xhr: true

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('pairing-board')
    end

    it 'rejects unauthorised members' do
      login(Fabricate(:member))
      target = event.pairings.ordered.first

      post :create, params: { event_id: event.slug, invitation_id: second_student.id, pairing_id: target.id }

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'pulls the invitation out into a fresh solo pairing' do
      delete :destroy, params: { event_id: event.slug, invitation_id: student.id }

      expect(response).to redirect_to(admin_event_path(event))
      expect(event.pairings.count).to eq(3)
    end

    it 'returns 404 for unverified invitations without creating a pairing' do
      unverified = Fabricate(:invitation, event:, attending: true, verified: false)

      delete :destroy, params: { event_id: event.slug, invitation_id: unverified.id }

      expect(response).to have_http_status(:not_found)
      expect(PairingInvitation.exists?(invitation: unverified)).to be(false)
    end
  end
end
