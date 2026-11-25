require 'spec_helper'

RSpec.describe WorkshopInvitationWorkingGroup do
  let(:workshop) { Fabricate(:workshop) }
  let(:group) { WorkshopWorkingGroup.create!(workshop:, position: 1) }

  def checked_in_invitation(target_workshop: workshop, role: 'Student')
    Fabricate(:workshop_invitation,
              workshop: target_workshop,
              role:,
              attending: true,
              attended: true,
              checked_in_at: Time.zone.now,
              automated_rsvp: true)
  end

  it 'links a checked-in workshop invitation to a working group' do
    invitation = checked_in_invitation(role: 'Student')
    membership = described_class.create!(workshop_working_group: group, workshop_invitation: invitation)

    expect(invitation.reload.workshop_working_group).to eq(group)
    expect(group.workshop_invitations).to contain_exactly(invitation)
    expect(membership).to be_persisted
  end

  it 'rejects an invitation that is not checked in' do
    invitation = Fabricate(:workshop_invitation, workshop:, role: 'Student', attending: true, attended: nil, automated_rsvp: true)
    membership = described_class.new(workshop_working_group: group, workshop_invitation: invitation)

    expect(membership).not_to be_valid
    expect(membership.errors[:workshop_invitation]).to include('must be checked in to join a working group')
  end

  it 'rejects an invitation from a different workshop' do
    other_workshop = Fabricate(:workshop)
    invitation = checked_in_invitation(target_workshop: other_workshop, role: 'Student')
    membership = described_class.new(workshop_working_group: group, workshop_invitation: invitation)

    expect(membership).not_to be_valid
    expect(membership.errors[:workshop_invitation]).to include('must belong to the same workshop')
  end

  it 'enforces that an invitation belongs to at most one working group' do
    invitation = checked_in_invitation(role: 'Student')
    other_group = WorkshopWorkingGroup.create!(workshop:, position: 2)
    described_class.create!(workshop_working_group: group, workshop_invitation: invitation)

    duplicate = described_class.new(workshop_working_group: other_group, workshop_invitation: invitation)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:workshop_invitation_id]).to be_present
  end

  it 'supports multiple attendees of the same role in one working group' do
    first_student = checked_in_invitation(role: 'Student')
    second_student = checked_in_invitation(role: 'Student')
    described_class.create!(workshop_working_group: group, workshop_invitation: first_student)

    second = described_class.create!(workshop_working_group: group, workshop_invitation: second_student)
    expect(second).to be_persisted
    expect(group.workshop_invitations).to contain_exactly(first_student, second_student)
  end
end
