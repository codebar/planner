class Sponsor < ActiveRecord::Base
  require 'uri'

  enum level: {
    hidden: 0, # hidden from the sponsors page but still visible on event pages
    standard: 1,
    bronze: 2,
    silver: 3,
    gold: 4,
  }

  has_one :address
  has_many :chapters, through: :workshops
  has_many :workshop_sponsors
  has_many :workshops, through: :workshop_sponsors
  has_many :member_contacts
  has_many :contacts, through: :member_contacts, class_name: 'Member', foreign_key: 'member_id'

  validates :name, :address, :avatar, :website, :seats, presence: true
  validate :website_is_url

  default_scope -> { order('updated_at desc') }
  scope :active, -> { where.not(level: 'hidden') }

  scope :recent_for_chapter, -> (chapter) {
    distinct
      .unscope(:order)
      .includes(:workshops)
      .joins(:workshops, :chapters)
      .where(chapters: {id: chapter.id})
      .order('workshops.date_and_time DESC')
      .limit(6)
  }

  mount_uploader(:avatar, AvatarUploader)

  accepts_nested_attributes_for :address, :contacts

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
      valid = uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
    rescue URI::InvalidURIError
      valid = false
    end
    errors.add(:website, 'must be a full, valid URL') unless valid
  end
end
