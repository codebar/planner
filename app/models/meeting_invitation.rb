class MeetingInvitation < ActiveRecord::Base
  include InvitationConcerns

  belongs_to :meeting
  belongs_to :member

  validates :meeting, :member, presence: true
  validates :member_id, uniqueness: { scope: [:meeting_id] }

  scope :accepted, -> { where(attending: true) }
  scope :attended, -> { where(attended: true) }

  alias event meeting
end
