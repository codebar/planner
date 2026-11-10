class Chapter < ApplicationRecord
  CONTACT_AUDIENCES = %w[
    all_members chapter_organisers custom_list active_last_month inactive_last_month event_rsvp
  ].freeze
  CONTACT_RSVP_STATUSES = %w[attending declined unanswered].freeze

  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  validates :name, :email, uniqueness: true, presence: true
  validates :city, presence: true
  validates :time_zone, presence: true
  validate  :time_zone_exists
  validates :description, length: { maximum: 280 }

  has_many :workshops
  has_and_belongs_to_many :events, join_table: 'chapters_events'
  has_many :groups
  has_many :sponsors, through: :workshops
  has_many :subscriptions, through: :groups
  # Kept subscriptions only: tombstoned rows record past periods, not current membership.
  has_many :members, -> { where(subscriptions: { discarded_at: nil }) }, through: :subscriptions
  has_many :feedbacks, through: :workshops

  before_save :set_slug

  scope :active, -> { where(active: true) }

  delegate :upcoming, to: :workshops, prefix: true

  mount_uploader(:image, ImageUploader)

  def self.available_to_user(user)
    return Chapter.all if user.has_role?(:organiser) || user.has_role?(:admin) || user.has_role?(:organiser, Chapter)

    Chapter.find_roles(:organiser, user).map(&:resource)
  end

  def organisers
    @organisers ||= Member.with_role(:organiser, self)
  end

  def contact_members
    members.distinct.order(:name, :surname)
  end

  def contact_events
    events.order(date_and_time: :desc)
  end

  def contact_recipients(audience, member_ids = [], event_id: nil, rsvp_status: nil)
    recipients = case audience
                 when 'all_members' then members
                 when 'chapter_organisers' then organisers
                 when 'custom_list' then members.where(id: member_ids)
                 when 'active_last_month' then members.with_activity_since(1.month.ago)
                 when 'inactive_last_month' then members.without_activity_since(1.month.ago)
                 when 'event_rsvp' then recipients_by_event_rsvp(event_id, rsvp_status)
                 else Member.none
    end
    recipients.distinct
  end

  # All members subscribed to this chapter's Students group, regardless of ban or TOC status.
  # Use #eligible_students when building invitation lists.
  def students
    members_for_group('Students')
  end

  # All members subscribed to this chapter's Coaches group, regardless of ban or TOC status.
  # Use #eligible_coaches when building invitation lists.
  def coaches
    members_for_group('Coaches')
  end

  # Chapter students who are not banned and have accepted the TOC — safe to invite to workshops.
  def eligible_students
    Member.in_group(groups.students).distinct
  end

  # Chapter coaches who are not banned and have accepted the TOC — safe to invite to workshops.
  def eligible_coaches
    Member.in_group(groups.coaches).distinct
  end

  private

  def recipients_by_event_rsvp(event_id, rsvp_status)
    return Member.none unless CONTACT_RSVP_STATUSES.include?(rsvp_status)

    event = contact_events.find_by(id: event_id)
    return Member.none unless event

    attending = { 'attending' => true, 'declined' => false, 'unanswered' => nil }.fetch(rsvp_status)
    members.where(id: event.invitations.where(attending:).select(:member_id))
  end

  def members_for_group(name)
    members.where(groups: { name: }).distinct
  end

  def time_zone_exists
    return unless time_zone && ActiveSupport::TimeZone[time_zone].nil?

    errors.add(:time_zone, 'does not exist')
  end

  def set_slug
    self.slug ||= name.parameterize
  end
end
