class Group < ActiveRecord::Base
  NAMES = %w(Coaches Students)

  belongs_to :chapter
  has_many :subscriptions
  has_many :members, through: :subscriptions
  has_many :group_announcements
  has_many :announcements, through: :group_announcements

  scope :latest_members, -> { joins(:members).order('created_at') }
  scope :students, -> { where(name: 'Students') }
  scope :coaches, -> { where(name: 'Coaches') }

  validates :name, presence: true, inclusion: { in: NAMES, message: 'Invalid name for Group' }

  alias_attribute :city, :chapter

  default_scope -> { joins(:chapter) }

  def to_s
    "#{name} #{chapter.name}"
  end
end
