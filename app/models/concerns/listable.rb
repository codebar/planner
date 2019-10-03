module Listable
  NUMBER_OF_RECENT_WORKSHOPS_TO_RETRIEVE = 10.freeze

  extend ActiveSupport::Concern

  included do
    scope :upcoming, -> { where('date_and_time >= ?', Time.zone.now).order(date_and_time: :asc) }
    scope :past, -> { where('date_and_time < ?', Time.zone.now).order(:date_and_time) }
    scope :recent, -> { where('date_and_time < ?', Time.zone.now).order(date_and_time: :desc).limit(NUMBER_OF_RECENT_WORKSHOPS_TO_RETRIEVE) }
    scope :completed_since_yesterday, -> { where('date_and_time < ? and date_and_time > ?', Time.zone.now, Time.zone.now - 24.hours).order(:date_and_time) }
  end

  module ClassMethods
    def next
      unscoped.upcoming.load.first
    end

    def most_recent
      past.includes(:sponsors).load.first
    end
  end
end
