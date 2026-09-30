module Listable
  NUMBER_OF_RECENT_WORKSHOPS_TO_RETRIEVE = 10

  extend ActiveSupport::Concern

  included do
    scope :today_and_upcoming, -> { where('date_and_time >= ?', Time.zone.today).reorder(date_and_time: :asc) }
    scope :upcoming, -> { where('date_and_time >= ?', Time.zone.now).reorder(date_and_time: :asc) }
    scope :past, -> { where('date_and_time < ?', Time.zone.now).order(:date_and_time) }
    scope :recent, lambda {
      where('date_and_time < ?', Time.zone.now)
        .order(date_and_time: :desc)
        .limit(NUMBER_OF_RECENT_WORKSHOPS_TO_RETRIEVE)
    }
    scope :completed_since_yesterday, lambda {
      where('date_and_time < ? and date_and_time > ?', Time.zone.now, Time.zone.now - 24.hours)
        .order(:date_and_time)
    }
  end

  module ClassMethods
    def next
      unscoped.upcoming.load.first
    end

    # Returns the latest past record in a single-row query. Eager-loads what
    # the event card partial renders so callers (chapter show etag/fragment
    # keys) read the rendered records without extra queries. Sponsors and
    # workshop_host both go through workshop_sponsors: eager-loading them
    # together in one join loses the host, so the host is preloaded instead.
    def most_recent
      # id as the tie-breaker keeps the picked record deterministic when two
      # past records share a date_and_time.
      scope = past.reorder(date_and_time: :desc, id: :desc)
      if reflect_on_association(:workshop_host)
        scope.eager_load(:sponsors, :organisers).preload(workshop_host: :sponsor).first
      elsif reflect_on_association(:venue)
        scope.eager_load(:sponsors, :organisers).includes(:venue).first
      else
        scope.eager_load(:sponsors, :organisers).first
      end
    end
  end
end
