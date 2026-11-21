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

  before do
    organiser.add_role(:organiser, workshop.chapter)
  end

  describe 'authorization and guards' do
    it 'redirects non-organisers away from working groups endpoints' do
      login(member)

      get admin_workshop_working_groups_path(workshop), as: :json
      expect(response).to have_http_status(:found)
    end

    it 'rejects working group requests for virtual workshops' do
      virtual = Fabricate(:virtual_workshop, date_and_time: 10.minutes.from_now, ends_at: 2.hours.from_now)
      organiser.add_role(:organiser, virtual.chapter)
      login(organiser)

      post admin_workshop_working_groups_path(virtual),
           params: { invitation_id: student_a.id, target_invitation_id: coach_a.id },
           as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(virtual.workshop_working_groups).to be_empty
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
      expect(payload['invitations_html']).to include('students have been signed in')
      expect(payload['counts']['checked_in_students']).to eq(2)
      expect(payload['counts']['checked_in_coaches']).to eq(1)

      get admin_workshop_working_groups_path(workshop), headers: { 'If-None-Match' => etag }, as: :json
      expect(response).to have_http_status(:not_modified)
    end

    it 'invalidates the ETag when a new accepted RSVP is added so check-in lists stay synced' do
      get admin_workshop_working_groups_path(workshop), as: :json
      etag = response.headers['ETag']

      Fabricate(:workshop_invitation, workshop:, role: 'Coach', attending: true, attended: nil, automated_rsvp: true)
      get admin_workshop_working_groups_path(workshop), headers: { 'If-None-Match' => etag }, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST create and DELETE destroy' do
    before { login(organiser) }

    it 'pairs waiting attendees, adds a second student to a group, and unlinks back to waiting' do
      post admin_workshop_working_groups_path(workshop),
           params: { invitation_id: student_a.id, target_invitation_id: coach_a.id },
           as: :json
      expect(response).to have_http_status(:ok)

      group = workshop.workshop_working_groups.ordered.first

      post admin_workshop_working_groups_path(workshop),
           params: { invitation_id: student_b.id, target_group_id: group.id },
           as: :json
      expect(response).to have_http_status(:ok)

      board = WorkingGroups::Service.for(workshop).board
      expect(board.groups.first.students).to contain_exactly(student_a, student_b)
      expect(board.groups.first.coaches).to eq([coach_a])

      delete admin_workshop_invitation_working_group_path(workshop, student_b.id), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['counts']).to include('groups_count' => 2, 'waiting_count' => 1)
    end
  end
end
