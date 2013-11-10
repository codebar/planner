class Sponsor < ActiveRecord::Base
  has_one :address
  has_many :sponsor_sessions
  has_many :sessions, through: :sponsor_sessions

  validates :name, :address, :avatar, :website, presence: true

  scope :latest, -> { order("updated_at desc").limit(7) }
end
