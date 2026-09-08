# frozen_string_literal: true

module Admin
  module Dashboard
    # Horizontal SVG timeline: 180 days past, 90 days future. SVG viewBox is
    # 1000x122; today sits at x=667 (2/3). No JS — <title> provides tooltips.
    class WorkshopTimelineComponent < ViewComponent::Base
      def initialize(past:, future:, event_past: [], event_future: []) # rubocop:disable Lint/MissingSuper
        @past = past.sort
        @future = future.sort
        @event_past = event_past.sort
        @event_future = event_future.sort
      end

      private

      attr_reader :past, :future, :event_past, :event_future

      def range_start = (Time.zone.today - 180.days).beginning_of_day
      def range_end = (Time.zone.today + 90.days).end_of_day

      def x_for(date)
        fraction = (date.to_time - range_start) / (range_end - range_start)
        (fraction * 1000).round(1)
      end

      MAX_STACK = 3

      def stacked_markers(dates)
        dates.group_by(&:to_date).flat_map do |_day, day_dates|
          sorted = day_dates.sort_by(&:to_time)
          sorted.first(MAX_STACK).each_with_index.map do |date, i|
            { x: x_for(date), y: 40 - (i * 14), date:, stack: sorted.size > 1 ? sorted.size : nil }
          end
        end
      end
    end
  end
end
