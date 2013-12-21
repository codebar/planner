class Meeting < ActiveRecord::Base
  include Listable

  has_many :meeting_talks

  belongs_to :venue, class_name: "Sponsor"

  validates :date_and_time, :duration, :lanyrd_url, :venue, presence: true

  def title
    "#{I18n.l(date_and_time, format: :month)} Meeting"
  end

  def end_time
    date_and_time+duration*60
  end
end
