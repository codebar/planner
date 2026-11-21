class Pairing < ApplicationRecord
  belongs_to :event
  has_many :pairing_invitations, dependent: :destroy
  has_many :invitations, through: :pairing_invitations

  scope :ordered, -> { order(:position, :id) }
  scope :with_members, -> { ordered.includes(pairing_invitations: { invitation: :member }) }

  before_validation :set_position, on: :create
  validate :at_least_one_member

  def student_invitations
    member_invitations.select(&:for_student?)
  end

  def coach_invitations
    member_invitations.select(&:for_coach?)
  end

  # A pairing with members on only one side is still "waiting" on its
  # other side - the UI renders it dashed. Nothing else treats it
  # specially: it's the same Pairing, just with fewer members so far.
  def mixed?
    student_invitations.any? && coach_invitations.any?
  end

  def solo?
    pairing_invitations.size == 1
  end

  def self.check_in!(invitation)
    return unless eligible_for_pairing?(invitation)

    apply!(invitation.event, Board::CheckIn.new(invitation_id: invitation.id, role: invitation.role))
  end

  def self.add!(invitation, pairing)
    return unless eligible_for_pairing?(invitation) && pairing.event_id == invitation.event_id

    action = Board::Assign.new(invitation_id: invitation.id, role: invitation.role, target_group_id: pairing.id)
    apply!(invitation.event, action)
  end

  def self.pull_out!(invitation)
    return unless eligible_for_pairing?(invitation)

    apply!(invitation.event, Board::PullOut.new(invitation_id: invitation.id, role: invitation.role))
  end

  def self.remove!(invitation)
    return unless invitation.event.is_a?(Event)

    apply!(invitation.event, Board::Remove.new(invitation_id: invitation.id))
  end

  # Ensures any previously verified & attending invitations have a pairing
  # (e.g. events that already had checked-in attendees before this feature).
  def self.sync!(event)
    return unless event.is_a?(Event)

    actions = unpaired_check_in_actions(event)
    return if actions.empty?

    apply_many!(event, actions)
  end

  def self.apply!(event, action)
    apply_many!(event, [action])
  end
  private_class_method :apply!

  def self.apply_many!(event, actions)
    event.with_lock do
      pairings = event.pairings.ordered.includes(pairing_invitations: :invitation).to_a
      current_board = Board.from_pairings(pairings)
      next_board = actions.inject(current_board) { |state, action| state.reduce(action) }
      Reconciler.apply!(event, pairings, next_board) unless next_board == current_board
    end
  end
  private_class_method :apply_many!

  def self.unpaired_check_in_actions(event)
    event.invitations.accepted.verified
         .left_outer_joins(:pairing_invitation)
         .where(pairing_invitations: { id: nil })
         .reject(&:for_participant?)
         .map { |inv| Board::CheckIn.new(invitation_id: inv.id, role: inv.role) }
  end
  private_class_method :unpaired_check_in_actions

  def self.eligible_for_pairing?(invitation)
    invitation.event.is_a?(Event) && !invitation.for_participant?
  end
  private_class_method :eligible_for_pairing?

  private

  def member_invitations
    pairing_invitations.map(&:invitation)
  end

  def set_position
    self.position ||= (event&.pairings&.maximum(:position) || 0) + 1
  end

  def at_least_one_member
    errors.add(:base, 'must have at least one member') if member_invitations.none?
  end
end
