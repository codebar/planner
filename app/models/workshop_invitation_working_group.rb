class WorkshopInvitationWorkingGroup < ApplicationRecord
  belongs_to :workshop_working_group
  belongs_to :workshop_invitation

  validates :workshop_invitation_id, uniqueness: true
  validate :same_workshop
  validate :invitation_checked_in
  validate :unique_role_within_group

  private

  def same_workshop
    return unless workshop_working_group && workshop_invitation
    return if workshop_working_group.workshop_id == workshop_invitation.workshop_id

    errors.add(:workshop_invitation, 'must belong to the same workshop')
  end

  def invitation_checked_in
    return unless workshop_invitation
    return if workshop_invitation.attending? && workshop_invitation.attended?

    errors.add(:workshop_invitation, 'must be checked in to join a working group')
  end

  def unique_role_within_group
    return unless workshop_working_group && workshop_invitation&.role
    return unless duplicate_role_exists?

    errors.add(:workshop_invitation, "role #{workshop_invitation.role} is already filled in this working group")
  end

  def duplicate_role_exists?
    workshop_working_group
      .workshop_invitation_working_groups
      .joins(:workshop_invitation)
      .where(workshop_invitations: { role: workshop_invitation.role })
      .where.not(id:)
      .exists?
  end
end
