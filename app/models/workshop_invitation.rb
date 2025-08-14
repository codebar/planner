class WorkshopInvitation < ApplicationRecord
  include InvitationConcerns

  belongs_to :workshop
  belongs_to :member
  belongs_to :overrider, foreign_key: :last_overridden_by_id, class_name: 'Member', inverse_of: false, optional: true
  has_one :waiting_list, foreign_key: :invitation_id

  validates :workshop, :member, presence: true
  validates :member_id, uniqueness: { scope: %i[workshop_id role] }
  validates :role, inclusion: { in: %w[Student Coach], allow_nil: true }
  validates :tutorial, presence: true, if: lambda {
    student_attending? && !automated_rsvp
  }
  validates :tutorial, presence: true, on: :waitinglist, if: :student_attending?

  scope :year, ->(year) { joins(:workshop).where('EXTRACT(year FROM workshops.date_and_time) = ?', year) }
  scope :attended, -> { where(attended: true) }
  scope :accepted_or_attended, -> { where('attending=? or attended=?', true, true) }
  scope :to_students, -> { where(role: 'Student') }
  scope :to_coaches, -> { where(role: 'Coach') }
  scope :order_by_latest, -> { joins(:workshop).order('workshops.date_and_time desc') }
  scope :last_six_months, -> { joins(:workshop).where(workshops: { date_and_time: 6.months.ago...Time.zone.now }) }
  scope :not_reminded, -> { where(reminded_at: nil) }
  scope :on_waiting_list, -> { joins(:waiting_list) }
  scope :with_notes_and_their_authors, -> { includes(member: { member_notes: :author }) }

  def waiting_list_position
    @waiting_list_position ||= WaitingList.by_workshop(workshop)
                                          .where_role(role)
                                          .where(auto_rsvp: true)
                                          .order(:created_at)
                                          .map(&:invitation_id)
                                          .index(id) + 1
  end

  def parent
    workshop
  end

  alias event parent

  def student_attending?
    for_student? && attending.present?
  end

  def not_attending?
    attending == false
  end
end
