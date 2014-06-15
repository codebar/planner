class Group < ActiveRecord::Base
  belongs_to :chapter
  has_many :subscriptions
  has_many :members, through: :subscriptions

  scope :students, -> { where(name: 'Students') }
  scope :coaches, -> { where(name: 'Coaches') }

  validates :name, :chapter_id, presence: true

  alias_attribute :city, :chapter
end
