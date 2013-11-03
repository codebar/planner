class Sponsor < ActiveRecord::Base
  has_one :address
  has_many :sponsor_sessions
  has_many :sessions, through: :sponsor_sessions

  validates :name, :description, :address, presence: true
end