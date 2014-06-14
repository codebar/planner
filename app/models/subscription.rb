class Subscription < ActiveRecord::Base
  belongs_to :group
  belongs_to :member

  validates_uniqueness_of :group, scope: :member_id
end
