require 'spec_helper'

RSpec.describe InvitationPresenter do
  let(:admin) { Fabricate(:chapter_organiser) }
  let(:invitation) { Fabricate(:student_workshop_invitation) }
  let(:invitation_presenter) { InvitationPresenter.new(invitation) }

  it '#member' do
    expect(invitation_presenter.member).to eq(invitation.member)
  end

  context '#attendance_status' do
    it 'returns Attending when attending' do
      invitation.update_attribute(:attending, true)

      expect(invitation_presenter.attendance_status).to eq('Attending')
    end

    it 'returns RSVP when not attending' do
      expect(invitation_presenter.attendance_status).to eq('RSVP')
    end
  end

  context '#automated_rsvp_message' do
    it 'returns name of admin that set attending when manually edited' do
      audit = Auditor::Audit.new(invitation, :attending, admin)
      audit.log do
        invitation.update(
          attending: true,
          automated_rsvp: true,
          rsvp_time: Time.zone.now
        )
      end

      expect(invitation_presenter.automated_rsvp_message).to eq("Added by #{invitation.admin_set_attending}")
    end

    it 'returns waitlist message when user editied invitation' do
      audit = Auditor::Audit.new(invitation, :attending, invitation.member)
      audit.log do
        invitation.update(
          attending: true,
          automated_rsvp: true,
          rsvp_time: Time.zone.now
        )
      end

      expect(invitation_presenter.automated_rsvp_message).to eq('Waiting list')
    end
  end
end
