class Chapter < ActiveRecord::Base
  validates :name, uniqueness: true

  has_many :sessions
  has_many :groups

  scope :students, -> { joins(:group).where(group: { name: 'Students' }) }
  scope :coaches, -> { joins(:group).where(group: { name: 'Coaches' }) }
end
