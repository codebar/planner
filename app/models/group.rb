class Group < ActiveRecord::Base
  belongs_to :chapter
  has_many :subscriptions
  has_many :members, through: :subscriptions

  validates :name, :chapter_id, presence: true
end
