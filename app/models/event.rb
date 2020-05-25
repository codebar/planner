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
  validates :slug, uniqueness: true
  validate :invitability, if: :invitable?
  validates :coach_spaces, :student_spaces, numericality: true

  before_save do
    begins_at = Time.parse(self.begins_at)
    self.date_and_time = date_and_time.change(hour: begins_at.hour, min: begins_at.min)
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

  def coaches_only?
    student_spaces.zero?
  end

  def students_only?
    coach_spaces.zero?
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

  def invitability
    errors.add(:coach_spaces, :required) if coach_spaces.blank?
    errors.add(:student_spaces, :required) if student_spaces.blank?
    errors.add(:invitable, :all_invitation_details_required) \
      if coach_spaces.blank? || student_spaces.blank?
  end

  def student_emails
    invitations.students.where(attending: true).map { |i| i.member.email }
  end

  def coach_emails
    invitations.coaches.where(attending: true).map { |i| i.member.email }
  end

  def permitted_audience_values
    %w[Students Coaches]
  end
end
