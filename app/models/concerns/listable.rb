module Listable
  NUMBER_OF_RECENT_WORKSHOPS_TO_RETRIEVE = 10.freeze

  extend ActiveSupport::Concern

  included do
    scope :upcoming, -> { where('date_and_time >= ?', Time.zone.now).order(:date_and_time) }
    scope :past, -> { where('date_and_time < ?', Time.zone.now).order(:date_and_time) }
    scope :recent, -> { where('date_and_time < ?', Time.zone.now).order(date_and_time: :desc).limit(NUMBER_OF_RECENT_WORKSHOPS_TO_RETRIEVE) }
  end

  module ClassMethods
    def next
      unscoped.upcoming.load.first
    end

    def most_recent
      past.load.first
    end
  end
end
