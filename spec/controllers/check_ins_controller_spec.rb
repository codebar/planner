# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckInsController do
  let(:member) { Fabricate(:member) }
  let(:event) do
    Fabricate(:event,
              date_and_time: Time.zone.now - 30.minutes,
              ends_at: Time.zone.now + 30.minutes)
  end
  let(:future_event) { Fabricate(:event) }

  describe 'GET new' do
    it 'renders the role selection page when logged in' do
      login(member)
      get :new, params: { code: event.check_in_code }
      expect(response).to be_successful
    end

    it 'redirects to auth when not logged in' do
      get :new, params: { code: event.check_in_code }
      expect(response).to redirect_to('/auth/codebar')
    end
  end

  describe 'POST create' do
    it 'redirects to auth when not logged in' do
      post :create, params: { code: event.check_in_code, role: 'Student' }
      expect(response).to redirect_to('/auth/codebar')
    end

    context 'when logged in' do
      before { login(member) }

      it 'creates an invitation with source=check_in' do
        post :create, params: { code: event.check_in_code, role: 'Student' }
        invitation = Invitation.find_by(event:, member:)
        expect(invitation.source).to eq(InvitationConcerns::SOURCE_CHECK_IN)
        expect(invitation.attending).to be true
        expect(invitation.verified).to be true
        expect(response).to redirect_to(check_in_e_confirm_path(code: event.check_in_code))
      end

      it 'rejects check-in when the event is not open' do
        post :create, params: { code: future_event.check_in_code, role: 'Student' }
        expect(response).to redirect_to(check_in_e_path(code: future_event.check_in_code))
        expect(flash[:alert]).to eq('Check-in is not currently open.')
      end

      it 'rejects an invalid role' do
        post :create, params: { code: event.check_in_code, role: 'Hacker' }
        expect(response).to redirect_to(check_in_e_path(code: event.check_in_code))
        expect(flash[:alert]).to be_present
      end

      it 'ignores unpermitted parameters' do
        post :create, params: { code: event.check_in_code, role: 'Student', hacker_field: 'malicious' }
        invitation = Invitation.find_by(event:, member:)
        expect(invitation.source).to eq(InvitationConcerns::SOURCE_CHECK_IN)
        expect(response).to redirect_to(check_in_e_confirm_path(code: event.check_in_code))
      end

      it 'redirects to confirm when already checked in' do
        invitation = Fabricate(:invitation, event:, member:, role: 'Student', attending: true, verified: true)
        post :create, params: { code: event.check_in_code, role: 'Student' }
        expect(response).to redirect_to(check_in_e_confirm_path(code: event.check_in_code))
        expect(Invitation.find(invitation.id).verified).to be true
      end

      it 'rejects selecting a different role than the existing invitation' do
        Fabricate(:invitation, event:, member:, role: 'Student')
        post :create, params: { code: event.check_in_code, role: 'Coach' }
        expect(response).to redirect_to(check_in_e_path(code: event.check_in_code))
        expect(flash[:alert]).to include('Student')
      end

      it 'rejects check-in when the role is at capacity' do
        event.update!(student_spaces: 1)
        Fabricate(:invitation, event:, member: Fabricate(:member), role: 'Student',
                               attending: true, verified: true)
        post :create, params: { code: event.check_in_code, role: 'Student' }
        expect(response).to redirect_to(check_in_e_path(code: event.check_in_code))
        expect(flash[:alert]).to include('no Student spaces left')
      end

      it 'checks in for a workshop and marks attended' do
        workshop = Fabricate(:workshop,
                             date_and_time: Time.zone.now - 30.minutes,
                             ends_at: Time.zone.now + 30.minutes)
        post :create, params: { code: workshop.check_in_code, role: 'Student' }
        invitation = WorkshopInvitation.find_by(workshop:, member:)
        expect(invitation.source).to eq(InvitationConcerns::SOURCE_CHECK_IN)
        expect(invitation.attending).to be true
        expect(invitation.attended).to be true
        expect(invitation.automated_rsvp).to be true
        expect(response).to redirect_to(check_in_w_confirm_path(code: workshop.check_in_code))
      end

      it 'rejects workshop check-in when the member is on the waiting list' do
        workshop = Fabricate(:workshop,
                             date_and_time: Time.zone.now - 30.minutes,
                             ends_at: Time.zone.now + 30.minutes)
        invitation = Fabricate(:workshop_invitation, workshop:, member:, role: 'Student')
        WaitingList.add(invitation)
        post :create, params: { code: workshop.check_in_code, role: 'Student' }
        expect(response).to redirect_to(check_in_w_path(code: workshop.check_in_code))
        expect(flash[:alert]).to include('waiting list')
      end
    end
  end
end
