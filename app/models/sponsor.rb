class Sponsor < ActiveRecord::Base
  has_one :address
  has_many :sponsor_sessions
  has_many :sessions, through: :sponsor_sessions

  validates :name, :address, :avatar, :website, :seats, presence: true

  mount_uploader(:avatar, AvatarUploader) unless Rails.env.test?

  accepts_nested_attributes_for :address

  scope :latest, -> { order("updated_at desc").limit(4) }

  def coach_spots
    number_of_coaches || (seats/2.0).round
  end
end
