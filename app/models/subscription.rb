class Subscription < ActiveRecord::Base
  belongs_to :group
  belongs_to :member

  validates_uniqueness_of :group, scope: :member_id
  default_scope -> { order(:created_at) }

  def student?
    group.name.downcase == "students"
  end

  def coach?
    group.name.downcase == "coaches"
  end
end
