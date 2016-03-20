class MeetingInvitation < ActiveRecord::Base
  include InvitationConcerns

  validates :meeting, :member, presence: true

  belongs_to :meeting
  belongs_to :member

  scope :accepted, -> { where(attending: true) }
  scope :attended, -> { where(attended: true)}

  def attended?
    self.attended
  end
end