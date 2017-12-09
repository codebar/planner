class MeetingInvitation < ActiveRecord::Base
  include InvitationConcerns

  validates :meeting, :member, presence: true
  validates :member_id, uniqueness: { scope: [:meeting_id] }

  belongs_to :meeting
  belongs_to :member

  scope :accepted, -> { where(attending: true) }
  scope :attended, -> { where(attended: true)}
end
