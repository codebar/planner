class Sponsor < ActiveRecord::Base
  include Auditor::Model

  self.per_page = 50
  require 'uri'

  enum level: {
    hidden: 0, # hidden from the sponsors page but still visible on event pages
    standard: 1,
    bronze: 2,
    silver: 3,
    gold: 4,
    community: 5
  }

  has_one :address
  has_many :chapters, through: :workshops
  has_many :contacts
  has_many :meetings, -> { order(date_and_time: :desc) }, foreign_key: 'venue_id', inverse_of: :venue
  has_many :event_sponsorships, -> { includes([:event]).joins(:event).order('events.date_and_time desc') },
           class_name: 'Sponsorship', inverse_of: :sponsor
  has_many :events, through: :event_sponsorships
  has_many :workshop_sponsors, lambda {
    includes([workshop: :chapter])
      .joins(:workshop)
      .order('workshops.date_and_time desc')
  },
           inverse_of: :sponsor
  has_many :workshops, through: :workshop_sponsors

  accepts_nested_attributes_for :contacts, reject_if: :invalid_contact?, allow_destroy: true
  accepts_nested_attributes_for :address

  validates :level, inclusion: { in: Sponsor.levels.keys }
  validates :name, :address, :avatar, :website, :level, presence: true
  validate :website_is_url, if: :website?
  validates :number_of_coaches, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :seats, presence: true, numericality: { greater_tha_or_equal_to: 0, only_integer: true }

  default_scope -> { order('updated_at desc') }
  scope :active, -> { where.not(level: 'hidden') }
  scope :by_name, ->(name) { where('lower(sponsors.name) like ?', "%#{name.downcase}%") }

  scope :recent_for_chapter, lambda { |chapter|
    distinct
      .unscope(:order)
      .includes(:workshops)
      .joins(:workshops, :chapters)
      .where(chapters: { id: chapter.id })
      .order('workshops.date_and_time DESC')
      .limit(6)
  }

  mount_uploader(:avatar, AvatarUploader)

  def coach_spots
    number_of_coaches || (seats / 2.0).round
  end

  def self.latest
    WorkshopSponsor.order('created_at desc').limit(15).includes(:sponsor).map(&:sponsor).uniq
  end

  private

  def website_is_url
    begin
      uri = URI.parse(website)
      valid = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      valid = false
    end
    errors.add(:website, 'must be a full, valid URL') unless valid
  end

  def invalid_contact?(attrs)
    attrs['name'].blank? && attrs['surname'].blank? && attrs['email'].blank?
  end
end
