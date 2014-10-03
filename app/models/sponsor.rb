class Sponsor < ActiveRecord::Base
  require 'uri'
  has_one :address
  has_many :sponsor_sessions
  has_many :sessions, through: :sponsor_sessions

  validates :name, :address, :avatar, :website, :seats, presence: true
  validate :website_is_url

  mount_uploader(:avatar, AvatarUploader) unless Rails.env.test? or Rails.env.development?

  accepts_nested_attributes_for :address

  scope :latest, -> { joins(:sponsor_sessions).order("created_at desc").limit(15) }

  def coach_spots
    number_of_coaches || (seats/2.0).round
  end

  private
  def website_is_url
    begin
      uri = URI.parse(website)
      valid = uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
    rescue URI::InvalidURIError
      valid = false
    end
    errors.add(:website, "must be a full, valid URL") unless valid
  end
end
