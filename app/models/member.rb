class Member < ApplicationRecord
  include Permissions

  enum :how_you_found_us, {
    from_a_friend: 0,
    search_engine: 1,
    social_media: 2,
    codebar_host_or_partner: 3,
    other: 4
  }

  has_many :attendance_warnings
  has_many :bans
  has_many :eligibility_inquiries
  has_many :workshop_invitations
  has_many :invitations
  has_many :auth_services
  has_many :feedbacks, foreign_key: :coach_id
  has_many :subscriptions
  has_many :groups, through: :subscriptions
  has_many :member_notes
  has_many :chapters, -> { distinct }, through: :groups
  has_many :announcements, -> { distinct }, through: :groups
  has_many :meeting_invitations
  has_many :member_email_deliveries

  validates :auth_services, presence: true
  validates :name, :surname, :email, :about_you, presence: true, if: :can_log_in?
  validates :email, uniqueness: true
  validates :about_you, length: { maximum: 255 }

  DIETARY_RESTRICTIONS = %w[vegan vegetarian pescetarian halal gluten_free dairy_free other].freeze
  validates :dietary_restrictions, inclusion: { in: DIETARY_RESTRICTIONS }
  validates :other_dietary_restrictions, presence: { if: :other_dietary_restrictions? }

  scope :accepted_toc, -> { where.not(accepted_toc_at: nil) }
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
  scope :in_group, lambda { |members|
    not_banned.accepted_toc.joins(:groups).where(groups: { id: members.select(:id) })
  }

  scope :with_skill, ->(skill_name) { tagged_with(skill_name) }

  scope :admin, -> { with_role(:admin) }
  scope :organiser, -> { with_role(:organiser, :any) }
  scope :manager, -> { admin.or(organiser).distinct }

  scope :sort_alphabetically, -> { order(:name, :surname) }

  acts_as_taggable_on :skills

  attr_accessor :attendance, :newsletter

  def manager?
    is_admin? || has_role?(:organiser, :any)
  end

  def banned?
    bans.active.present? || bans.permanent.present?
  end

  def banned_permanently?
    bans.permanent.present?
  end

  def name_and_surname
    [name, surname].compact.join ' '
  end

  def full_name
    pronoun = pronouns.present? ? "(#{pronouns})" : nil
    [name_and_surname, pronoun].compact.join ' '
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
    @upcoming_rsvps ||= rsvps(period: :upcoming)
  end

  def past_rsvps
    @past_rsvps ||= rsvps(period: :past).reverse
  end

  def attending_event_ids
    @attending_event_ids ||= begin
      event_ids     = invitations.accepted.pluck(:event_id)
      workshop_ids  = workshop_invitations.accepted.pluck(:workshop_id)
      meeting_ids   = meeting_invitations.accepted.pluck(:meeting_id)
      (event_ids + workshop_ids + meeting_ids).to_set
    end
  end

  def clear_attending_event_ids_cache!
    @attending_event_ids = nil
  end

  def flag_to_organisers?
    multiple_no_shows? && attendance_warnings.last_six_months.length >= 2
  end

  def multiple_no_shows?
    last_six_month_rsvps = workshop_invitations.taken_place.last_six_months.accepted
    (last_six_month_rsvps.length - last_six_month_rsvps.attended.length) > 3
  end

  def recent_notes
    last_five_workshops = workshop_invitations.order_by_latest.attended.take(5)
    return [] if last_five_workshops.empty?

    # Take 1 day out to include notes added on the previous day of the workshop
    notes_from_date = last_five_workshops.last.workshop.date_and_time - 1.day

    member_notes.where('created_at > ?', notes_from_date)
  end

  def other_dietary_restrictions?
    dietary_restrictions.present? && dietary_restrictions.include?('other')
  end

  def self.find_members_by_name(name)
    name.strip!
    name.eql?('') ? none : where("CONCAT(name, ' ', surname) ILIKE ?", "%#{name}%")
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

  def rsvps(period:)
    time_period = "#{period}_rsvps"

    [invitations.joins(:event),
     workshop_invitations.joins(:workshop).includes(workshop: :chapter),
     meeting_invitations.joins(:meeting)].map(&time_period.to_sym).inject(:+).sort_by { |i| i.event.date_and_time }
  end
end
