class Sponsor < ActiveRecord::Base
  require 'uri'

  enum level: {
    hidden: 0, # hidden from the sponsors page but still visible on event pages
    standard: 1,
    bronze: 2,
    silver: 3,
    gold: 4
  }

  has_one :address
  has_many :chapters, through: :workshops
  has_many :workshop_sponsors
  has_many :workshops, through: :workshop_sponsors
  has_many :member_contacts
  has_many :members, through: :member_contacts

  has_many :contacts
  accepts_nested_attributes_for :contacts, reject_if: :invalid_contact?
  accepts_nested_attributes_for :address

  validates :level, inclusion: { in: Sponsor.levels.keys }
  validates :name, :address, :avatar, :website, :level, presence: true
  validate :website_is_url, if: :website?

  default_scope -> { order('updated_at desc') }
  scope :active, -> { where.not(level: 'hidden') }

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
