class SessionInvitation < ActiveRecord::Base

  include InvitationConcerns

  belongs_to :sessions

  validates :sessions, :member, presence: true
  validates :member_id, uniqueness: { scope: [:sessions, :role ] }
  validates_inclusion_of :role, in: [ "Student", "Coach" ], allow_nil: true

  scope :attended, -> { where(attended: true) }
  scope :to_students, -> { where(role: "Student") }
  scope :to_coaches, -> { where(role: "Coach") }
  scope :by_member, -> { group(:member_id) }


  def parent
    sessions
  end

  def send_spots_available
    if role.eql?("Student")
      SessionInvitationMailer.spots_available(self.sessions, self.member, self).deliver if attending.eql?(nil)
    end
  end

  private

  def email
    if role.eql?("Student")
      SessionInvitationMailer.invite_student(self.sessions, self.member, self).deliver
    end
  end

end
