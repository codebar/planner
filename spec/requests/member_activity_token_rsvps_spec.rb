require 'rails_helper'

RSpec.describe 'Token-based workshop RSVP activity' do
  let(:invitation) { Fabricate(:workshop_invitation) }
  let(:member) { invitation.member }

  it 'records workshop_invitation.rsvp on accept' do
    invitation.workshop.update!(date_and_time: 2.days.from_now, rsvp_closes_at: 1.day.from_now)
    # Setup the @workshop presenter for available_spaces? — the fabricator's default 10 student seats satisfy
    post accept_invitation_path(invitation.token)

    expect(PublicActivity::Activity.exists?(owner: member, key: 'workshop_invitation.rsvp')).to be(true)
  end

  it 'records workshop_invitation.rejected on reject' do
    invitation.update!(attending: true)

    get reject_invitation_path(invitation.token)

    expect(PublicActivity::Activity.exists?(owner: member, key: 'workshop_invitation.rejected')).to be(true)
  end

  it 'records waiting_list.joined and waiting_list.left' do
    # Make workshop full so the invitation can be on waiting list
    invitation.workshop.update!(student_spaces: 0)
    invitation.update!(attending: false, role: 'Student')

    post invitation_waiting_list_path(invitation)
    expect(PublicActivity::Activity.exists?(owner: member, key: 'waiting_list.joined')).to be(true)

    delete invitation_waiting_list_path(invitation)
    expect(PublicActivity::Activity.exists?(owner: member, key: 'waiting_list.left')).to be(true)
  end
end
