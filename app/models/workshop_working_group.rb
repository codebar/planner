class WorkshopWorkingGroup < ApplicationRecord
  belongs_to :workshop
  has_many :workshop_invitation_working_groups, dependent: :destroy
  has_many :workshop_invitations, through: :workshop_invitation_working_groups

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :at_most_one_per_role

  scope :ordered, -> { order(:position, :id) }

  private

  def at_most_one_per_role
    roles = workshop_invitation_working_groups
            .reject(&:marked_for_destruction?)
            .filter_map { |membership| membership.workshop_invitation&.role }
    return unless roles.tally.values.any? { |count| count > 1 }

    errors.add(:base, 'A working group can have at most one student and one coach')
  end
end
