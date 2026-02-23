class Invitation < ApplicationRecord
  include InvitationConcerns

  belongs_to :event
  belongs_to :member
  belongs_to :verified_by, class_name: 'Member', optional: true

  validates :event, :member, presence: true
  validates :member_id, uniqueness: { scope: %i[event_id role] }
  validates :role, inclusion: { in: %w[Student Coach] }

  scope :students, -> { where(role: 'Student') }
  scope :coaches, -> { where(role: 'Coach') }
  scope :verified, -> { where(verified: true).order(:updated_at) }

  after_save :clear_member_cache, if: :saved_change_to_attending?

  def student_spaces?
    for_student? && event.student_spaces?
  end

  def coach_spaces?
    for_coach? && event.coach_spaces?
  end

  def to_param
    token
  end

  private

  def clear_member_cache
    member.clear_attending_event_ids_cache!
  end
end
