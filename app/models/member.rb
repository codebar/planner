class Member < ActiveRecord::Base
  include Permissions

  self.per_page = 80

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

  def upcoming_rsvps
    @upcoming_rsvps ||= (invitations.joins(:event).upcoming_rsvps +
                         workshop_invitations.joins(:workshop).includes(workshop: :chapter).upcoming_rsvps +
                         meeting_invitations.joins(:meeting).upcoming_rsvps)
                        .sort_by { |i| i.event.date_and_time }
  end

  def flag_to_organisers?
    multiple_no_shows? && attendance_warnings.last_six_months.length >= 2
  end

  def multiple_no_shows?
    last_six_month_rsvps = workshop_invitations.taken_place.last_six_months.accepted
    (last_six_month_rsvps.length - last_six_month_rsvps.attended.length) > 3
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
