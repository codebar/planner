class Invitation < ActiveRecord::Base
  include InvitationConcerns

  validates :event, :member, presence: true
  validates :member_id, uniqueness: { scope: %i[event_id role] }
  validates_inclusion_of :role, in: ['Student', 'Coach']

  belongs_to :event
  belongs_to :member
  belongs_to :verified_by, class_name: 'Member'

  scope :students, -> { where(role: 'Student') }
  scope :coaches, -> { where(role: 'Coach') }
  scope :verified, -> { where(verified: true).order(:updated_at) }

  def student_spaces?
    for_student? && event.student_spaces?
  end

  def coach_spaces?
    for_coach? && event.coach_spaces?
  end

  def to_param
    token
  end
end
