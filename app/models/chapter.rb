class Chapter < ActiveRecord::Base
  resourcify :permissions, role_cname: 'Permission', role_table_name: :permission

  validates :name, :email, uniqueness: true, presence: true
  validates  :city, presence: true

  has_many :workshops, class_name: Sessions
  has_many :groups
  has_many :sponsors, through: :workshops
  has_many :subscriptions, through: :groups
  has_many :members, -> { select("subscriptions.created_at, members.*").order('subscriptions.created_at asc') }, through: :groups

  def self.available_to_user(user)
    return Chapter.all if user.has_role?(:organiser) or user.has_role?(:admin) or user.has_role?(:organiser, Chapter)
    return Chapter.find_roles(:organiser, user).map(&:resource)
    []
  end

  def organisers
    @organisers ||= Member.with_role(:organiser, self)
  end
end
