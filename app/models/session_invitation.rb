class SessionInvitation < ActiveRecord::Base
  include InvitationConcerns

  belongs_to :workshop
  has_one :waiting_list, foreign_key: :invitation_id

  validates :workshop, :member, presence: true
  validates :member_id, uniqueness: { scope: [:workshop_id, :role ] }
  validates_inclusion_of :role, in: [ "Student", "Coach" ], allow_nil: true

  scope :attended, -> { where(attended: true) }
  scope :to_students, -> { where(role: "Student") }
  scope :to_coaches, -> { where(role: "Coach") }
  scope :by_member, -> { group(:member_id) }
  scope :order_by_latest, -> { joins(:workshop).order('workshops.date_and_time desc') }

  def waiting_list_position
    @waiting_list_position ||= WaitingList.by_workshop(self.workshop).where_role(self.role).where(auto_rsvp: true).order(:created_at).map(&:invitation_id).index(self.id)+1
  end

  def parent
    workshop
  end

  def email
    if for_student?
      SessionInvitationMailer.invite_student(self.workshop, self.member, self).deliver_now
    end
  end
end
