class Subscription < ApplicationRecord
  belongs_to :group
  belongs_to :member
  has_one :chapter, through: :group

  validates :group, uniqueness: { scope: :member_id }
  scope :ordered, -> { order(created_at: :desc) }

  def student?
    group.name.casecmp('students').zero?
  end

  def coach?
    group.name.casecmp('coaches').zero?
  end
end
