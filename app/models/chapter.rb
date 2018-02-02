class Chapter < ActiveRecord::Base
  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  validates :name, :email, uniqueness: true, presence: true
  validates :city, presence: true
  validates :time_zone, presence: true
  validate :time_zone_exists

  has_many :workshops
  has_and_belongs_to_many :events
  has_many :groups
  has_many :sponsors, through: :workshops
  has_many :subscriptions, through: :groups
  has_many :members, through: :subscriptions

  before_save :set_slug

  default_scope -> { where(active: true) }

  def self.available_to_user(user)
    return Chapter.all if user.has_role?(:organiser) || user.has_role?(:admin) || user.has_role?(:organiser, Chapter)
    return Chapter.find_roles(:organiser, user).map(&:resource)
  end

  def organisers
    @organisers ||= Member.with_role(:organiser, self)
  end

  def students
    members.select(&:student?)
  end

  def coaches
    members.select(&:coach?)
  end

  private

  def time_zone_exists
    if time_zone && ActiveSupport::TimeZone[time_zone].nil?
      errors.add(:time_zone, 'does not exist')
    end
  end

  def set_slug
    self.slug ||= self.name.parameterize
  end
end
