class MeetingInvitation < ActiveRecord::Base
  include InvitationConcerns

  validates :meeting, :member, presence: true

  belongs_to :meeting
  belongs_to :member

  scope :participants, -> { where(role: "Participant") }
  scope :accepted, -> { where(attending: true) }

  def attended?
    self.attended
  end
end