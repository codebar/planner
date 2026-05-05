class Group < ApplicationRecord
  NAMES = %w[Coaches Students].freeze

  belongs_to :chapter
  has_many :subscriptions
  has_many :members, through: :subscriptions
  has_many :group_announcements
  has_many :announcements, through: :group_announcements

  scope :latest_members, -> { joins(:members).order('created_at') }
  scope :students, -> { where(name: 'Students') }
  scope :coaches, -> { where(name: 'Coaches') }

  def self.members_by_recent_rsvp(group)
    group.members
         .joins('LEFT JOIN workshop_invitations ON workshop_invitations.member_id = members.id')
         .joins('LEFT JOIN workshops ON workshops.id = workshop_invitations.workshop_id')
         .select('members.*, MAX(workshops.date_and_time) as last_rsvp_at')
         .group('members.id')
         .order('MAX(workshops.date_and_time) DESC NULLS LAST')
  end

  validates :name, presence: true, inclusion: { in: NAMES, message: 'Invalid name for Group' }

  alias city chapter

  default_scope -> { joins(:chapter).includes(:chapter) }

  def to_s
    "#{name} #{chapter.name}"
  end

  def eligible_members
    members.not_banned.accepted_toc.distinct
  end
end
