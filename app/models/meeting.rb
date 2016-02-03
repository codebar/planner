class Meeting < ActiveRecord::Base
  include Listable
  include Invitable

  has_many :meeting_talks
  belongs_to :venue, class_name: "Sponsor"
  validates :date_and_time, :venue, presence: true

  before_save :set_slug

  def title
    self.name or "#{I18n.l(date_and_time, format: :month)} Meeting"
  end

  def to_s
    title
  end

  def to_param
    slug
  end

  def date
    I18n.l(date_and_time, format: :dashboard)
  end

  private

  def set_slug
    self.slug = "#{I18n.l(date_and_time, format: :year_month).downcase}-#{title.parameterize}" if self.slug.nil?
  end

end
