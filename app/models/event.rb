class Event < ActiveRecord::Base
  include Listable
  include Invitable

  attr_accessor :begins_at
  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  belongs_to :venue, class_name: 'Sponsor'
  has_many :sponsorships
  has_many :sponsors, through: :sponsorships
  has_many :organisers, -> { where('permissions.name' => 'organiser') }, through: :permissions, source: :members

  has_and_belongs_to_many :chapters

  has_many :invitations

  validates :name, :slug, :info, :schedule, :description, presence: true

  validate :invitability, if: :invitable?

  validates_numericality_of :coach_spaces, :student_spaces
  attr_accessor :publish_day, :publish_time

  scope :future, ->(n) { order('date_and_time').where('date_and_time > ?', Date.current).take(n) }

  before_save do
    begins_at = Time.parse(self.begins_at)
    self.date_and_time = self.date_and_time.change(hour: begins_at.hour, min: begins_at.min)
  end

  def to_s
    name
  end

  def to_param
    slug
  end

  def verified_coaches
    invitations.coaches.accepted.verified.map(&:member)
  end

  def verified_students
    invitations.students.accepted.verified.map(&:member)
  end

  def require_coach_questionnaire?
    coach_questionnaire.present?
  end

  def require_student_questionnaire?
    student_questionnaire.present?
  end

  def coaches_only?
    student_spaces == 0
  end

  def students_only?
    coach_spaces == 0
  end

  def coach_spaces?
    !students_only? && coach_spaces > attending_coaches.count
  end

  def student_spaces?
    !coaches_only? && student_spaces > attending_students.count
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  def update_date_and_time
    self.date_and_time = date_and_time.change(hour: time.hour, min: time.min)
  end

  def invitability
    errors.add(:coach_spaces, 'must be set') unless self.coach_spaces.present?
      errors.add(:student_space, 'must be set') unless self.student_spaces.present?
      errors.add(:invitable, 'Fill in all invitations details to make the event invitable') unless self.coach_spaces.present? && self.student_spaces.present?
  end

  def student_emails
    invitations.students.where(attending: true).map { |i| i.member.email }
  end

  def coach_emails
    invitations.coaches.where(attending: true).map { |i| i.member.email }
  end

  def permitted_audience_values
    ['Students', 'Coaches']
  end
end
