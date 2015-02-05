class SessionInvitation < ActiveRecord::Base
  include InvitationConcerns

  belongs_to :sessions
  has_one :waiting_list, foreign_key: :invitation_id

  validates :sessions, :member, presence: true
  validates :member_id, uniqueness: { scope: [:sessions_id, :role ] }
  validates_inclusion_of :role, in: [ "Student", "Coach" ], allow_nil: true

  scope :attended, -> { where(attended: true) }
  scope :to_students, -> { where(role: "Student") }
  scope :to_coaches, -> { where(role: "Coach") }
  scope :by_member, -> { group(:member_id) }

  def parent
    sessions
  end

  def email
    if for_student?
      SessionInvitationMailer.invite_student(self.sessions, self.member, self).deliver
    end
  end
end
