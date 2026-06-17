class Chapter < ApplicationRecord
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
  has_many :members, through: :subscriptions
  has_many :feedbacks, through: :workshops

  before_save :set_slug
  after_update_commit :expire_chapters_sidebar_cache
  after_create_commit :expire_chapters_sidebar_cache
  after_destroy_commit :expire_chapters_sidebar_cache

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

  def members_for_group(name)
    members.where(groups: { name: name }).distinct
  end

  def expire_chapters_sidebar_cache
    Rails.cache.delete('chapters-sidebar')
  end

  def time_zone_exists
    return unless time_zone && ActiveSupport::TimeZone[time_zone].nil?

    errors.add(:time_zone, 'does not exist')
  end

  def set_slug
    self.slug ||= name.parameterize
  end
end
