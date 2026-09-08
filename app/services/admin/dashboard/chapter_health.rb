# frozen_string_literal: true

module Admin
  module Dashboard
    # Health data for one chapter, shown in the Chapter Health card on
    # /admin/chapters/:id. Mirrors the classification rules used by
    # Admin::ChaptersController#status.
    class ChapterHealth
      Row = Data.define(:chapter, :bucket, :last_workshop_date, :next_workshop_date,
                        :days_since_last_workshop, :days_until_next_workshop,
                        :organiser_count, :eligible_students, :eligible_coaches,
                        :median_cadence_days)

      class << self
        # Health row for one chapter; per-chapter queries are fine on a show page.
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength — one entry per Row field
        def row(chapter:)
          in_window = chapter.workshops
                             .exists?(date_and_time: 180.days.ago.beginning_of_day..90.days.from_now)

          Row.new(
            chapter:,
            bucket: bucket_for(chapter, in_window),
            last_workshop_date: last_workshop_date = chapter.workshops.where(date_and_time: ..Time.zone.now)
                                                            .maximum(:date_and_time),
            next_workshop_date: next_workshop_date = chapter.workshops.today_and_upcoming.minimum(:date_and_time),
            days_since_last_workshop: recency_days(last_workshop_date),
            days_until_next_workshop: countdown_days(next_workshop_date),
            organiser_count: chapter.organisers.count,
            eligible_students: chapter.eligible_students.count,
            eligible_coaches: chapter.eligible_coaches.count,
            median_cadence_days: median_cadence(
              chapter.workshops.where(date_and_time: 180.days.ago..Time.zone.now).order(:date_and_time)
                              .pluck(:date_and_time)
            )
          )
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        private

        def recency_days(date)
          date && ((Time.zone.now - date) / 1.day).floor
        end

        def countdown_days(date)
          date && ((date - Time.zone.now) / 1.day).ceil
        end

        def median_cadence(dates) # rubocop:disable Metrics/AbcSize
          gaps = dates.sort.each_cons(2).map { |a, b| ((b - a) / 1.day).round }
          return nil if gaps.empty?

          mid = gaps.length / 2
          gaps.length.odd? ? gaps[mid] : ((gaps[mid - 1] + gaps[mid]) / 2.0).round
        end

        def bucket_for(chapter, in_window)
          return :inactive unless chapter.active?
          return :active if in_window

          :dormant
        end
      end
    end
  end
end
