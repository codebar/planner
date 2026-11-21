class WorkshopInvitationWorkingGroup < ApplicationRecord
  belongs_to :workshop_working_group
  belongs_to :workshop_invitation

  validates :workshop_invitation_id, uniqueness: true
  validate :same_workshop
  validate :invitation_checked_in

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
end
