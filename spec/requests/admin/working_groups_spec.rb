require 'spec_helper'

RSpec.describe 'Admin::WorkingGroups' do
  let(:organiser) { Fabricate(:member) }
  let(:member) { Fabricate(:member) }
  let(:workshop) { Fabricate(:workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now) }
  let!(:student_a) do
    Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: true, attended: true,
                                    checked_in_at: 10.minutes.ago, automated_rsvp: true,
                                    tutorial: 'Ruby Lesson 1', note: 'Working on arrays')
  end
  let!(:coach_a) do
    Fabricate(:workshop_invitation, workshop:, role: 'Coach', attending: true, attended: true,
                                    checked_in_at: 9.minutes.ago, automated_rsvp: true, note: 'Ruby & Rails')
  end
  let!(:student_b) do
    Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: true, attended: true,
                                    checked_in_at: 5.minutes.ago, automated_rsvp: true)
  end
  let!(:coach_b) do
    Fabricate(:workshop_invitation, workshop:, role: 'Coach', attending: true, attended: true,
                                    checked_in_at: 4.minutes.ago, automated_rsvp: true)
  end

  before do
    organiser.add_role(:organiser, workshop.chapter)
  end

  describe 'authorization' do
    it 'redirects non-organisers away from working groups endpoints' do
      login(member)

      get admin_workshop_working_groups_path(workshop), as: :json
      expect(response).to have_http_status(:found)
    end
  end

  describe 'GET /admin/workshops/:workshop_id/working_groups' do
    before { login(organiser) }

    it 'returns board JSON with ETag and 304 on matching If-None-Match without writing to DB' do
      expect do
        get admin_workshop_working_groups_path(workshop), as: :json
      end.not_to change(WorkshopWorkingGroup, :count)

      expect(response).to have_http_status(:ok)
      etag = response.headers['ETag']
      expect(etag).to be_present

      payload = response.parsed_body
      expect(payload['board_html']).to include('Pairings')
      expect(payload['counts']['checked_in_students']).to eq(2)
      expect(payload['counts']['checked_in_coaches']).to eq(2)

      get admin_workshop_working_groups_path(workshop), headers: { 'If-None-Match' => etag }, as: :json
      expect(response).to have_http_status(:not_modified)
    end
  end

  describe 'POST create and DELETE destroy' do
    before { login(organiser) }

    it 'pairs waiting attendees, swaps across groups, and unpairs back to waiting' do
      post admin_workshop_working_groups_path(workshop),
           params: { invitation_id: student_a.id, target_invitation_id: coach_a.id },
           as: :json
      post admin_workshop_working_groups_path(workshop),
           params: { invitation_id: student_b.id, target_invitation_id: coach_b.id },
           as: :json
      groups = workshop.workshop_working_groups.ordered
      expect(groups.count).to eq(2)

      post admin_workshop_working_groups_path(workshop),
           params: { invitation_id: student_a.id, target_group_id: groups.second.id },
           as: :json
      expect(response).to have_http_status(:ok)

      board = WorkingGroups::Service.for(workshop).board
      expect([board.groups.first.student, board.groups.second.student]).to eq([student_b, student_a])

      delete admin_workshop_invitation_working_group_path(workshop, student_a.id), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['counts']).to include('pairs' => 1, 'waiting_total' => 2)
    end
  end
end
