class Chapter < ActiveRecord::Base
  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  validates :name, :email, uniqueness: true, presence: true
  validates  :city, presence: true

  has_many :workshops
  has_and_belongs_to_many :events
  has_many :groups
  has_many :sponsors, through: :workshops
  has_many :subscriptions, through: :groups
  has_many :members, through: :subscriptions

  before_save :set_slug

  default_scope -> { where(active: true) }

  def self.available_to_user(user)
    return Chapter.all if user.has_role?(:organiser) or user.has_role?(:admin) or user.has_role?(:organiser, Chapter)
    return Chapter.find_roles(:organiser, user).map(&:resource)
    []
  end

  def organisers
    @organisers ||= Member.with_role(:organiser, self)
  end

  private

  def set_slug
    self.slug ||= self.name.parameterize
  end
end
