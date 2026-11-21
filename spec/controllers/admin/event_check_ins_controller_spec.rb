require 'rails_helper'

RSpec.describe Admin::EventCheckInsController do
  render_views

  let(:organiser) { Fabricate(:member) }
  let(:event) { Fabricate(:event, confirmation_required: true) }
  let(:student) { Fabricate(:invitation, event:, attending: true, verified: false) }
  let(:coach) { Fabricate(:coach_invitation, event:, attending: true, verified: false) }

  before do
    organiser.add_role(:organiser, event)
    login(organiser)
    student
    coach
  end

  describe 'POST #create' do
    it 'checks in the invitation and returns pairing metadata and board HTML on JSON XHR' do
      post :create, params: { event_id: event.slug, invitation_id: student.id }, format: :json, xhr: true

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(student.reload).to be_verified
      expect(body['invitation_id']).to eq(student.id)
      expect(body['partner_names']).to eq([])
      expect(body['board_html']).to include('pairing-board')
    end

    it 'returns partner names when auto-paired on check-in' do
      student.update!(verified: true)

      post :create, params: { event_id: event.slug, invitation_id: coach.id }, xhr: true

      body = response.parsed_body
      expect(body['partner_names']).to eq([student.member.full_name])
      expect(event.pairings.count).to eq(1)
    end

    it 'rejects unauthorised members' do
      login(Fabricate(:member))

      post :create, params: { event_id: event.slug, invitation_id: student.id }

      expect(response).to redirect_to(root_path)
      expect(student.reload).not_to be_verified
    end
  end

  describe 'DELETE #destroy' do
    it 'unchecks in the invitation and removes them from their pairing' do
      student.update!(verified: true)
      coach.update!(verified: true)

      delete :destroy, params: { event_id: event.slug, invitation_id: student.id }, xhr: true

      expect(response).to have_http_status(:ok)
      expect(student.reload).not_to be_verified
      expect(event.pairings.count).to eq(1)
      expect(event.pairings.first.invitations).to contain_exactly(coach)
    end
  end
end
