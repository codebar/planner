class Member < ActiveRecord::Base
  self.per_page = 80
  rolify role_cname: 'Permission', role_table_name: :permission, role_join_table_name: :members_permissions

  has_many :attendance_warnings
  has_many :bans
  has_many :eligibility_inquiries
  has_many :workshop_invitations
  has_many :invitations
  has_many :auth_services
  has_many :feedbacks, foreign_key: :coach_id
  has_many :jobs, foreign_key: :created_by_id
  has_many :subscriptions
  has_many :groups, through: :subscriptions
  has_many :member_notes
  has_many :chapters, -> { distinct }, through: :groups
  has_many :announcements, -> { distinct }, through: :groups
  has_many :meeting_invitations

  validates :auth_services, presence: true
  validates :name, :surname, :email, :about_you, presence: true, if: :can_log_in?
  validates :email, uniqueness: true
  validates :about_you, length: { maximum: 255 }

  scope :order_by_email, -> { order(:email) }
  scope :subscribers, -> { joins(:subscriptions).order('created_at desc').uniq }
  scope :not_banned, lambda {
                       joins('LEFT OUTER JOIN bans ON members.id = bans.member_id')
                         .where('bans.id is NULL or bans.expires_at < CURRENT_DATE')
                     }
  scope :attending_meeting, lambda { |meeting|
                              not_banned
                                .joins(:meeting_invitations)
                                .where('meeting_invitations.meeting_id = ? and meeting_invitations.attending = ?',
                                       meeting.id, true)
                            }
  scope :in_group, ->(group) { not_banned.joins(:groups).merge(group) }

  acts_as_taggable_on :skills

  attr_accessor :attendance, :newsletter

  def self.with_skill(skill_name)
    tagged_with(skill_name)
  end

  def banned?
    bans.active.present? || bans.permanent.present?
  end

  def banned_permanently?
    bans.permanent.present?
  end

  def more_than_two_absences?
    workshop_invitations.last_six_months.accepted.length - workshop_invitations.last_six_months.attended.length > 2
  end

  def full_name
    pronoun = pronouns.present? ? "(#{pronouns})" : nil
    [name, surname, pronoun].compact.join ' '
  end

  def student?
    groups.students.any?
  end

  def coach?
    groups.coaches.any?
  end

  def organised_chapters
    Chapter.with_role(:organiser, self)
  end

  def received_welcome_for?(subscription)
    return received_student_welcome_email if subscription.student?
    return received_coach_welcome_email if subscription.coach?

    true
  end

  def avatar(size = 100)
    "https://secure.gravatar.com/avatar/#{md5_email}?size=#{size}&default=identicon"
  end

  def requires_additional_details?
    can_log_in? && !valid?
  end

  def has_existing_RSVP_on(date)
    invitations_on(date).any?
  end

  def already_attending(event)
    invitations.where(attending: true).map { |e| e.event.id }.include?(event.id)
  end

  def is_organiser?
    organised_chapters.present?
  end

  def is_admin_or_organiser?
    has_role?(:admin) || is_organiser?
  end

  def is_monthlies_organiser?
    Meeting.with_role(:organiser, self).present?
  end

  private

  def invitations_on(date)
    workshop_invitations
      .joins(:workshop)
      .where('workshops.date_and_time BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day)
      .where(attending: true)
  end

  def md5_email
    Digest::MD5.hexdigest(email.strip.downcase)
  end
end
