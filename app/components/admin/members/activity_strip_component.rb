# frozen_string_literal: true

module Admin
  module Members
    class ActivityStripComponent < ViewComponent::Base
      CELL_WIDTH = 8
      CELL_GAP = 4
      STRIP_HEIGHT = 32
      MARKER_HEIGHT = 44
      MARKER_STROKE_WIDTH = 2
      MARKER_HIT_WIDTH = 10

      def initialize(weeks:, tracking_start_index: nil)
        super()
        @weeks = weeks
        @tracking_start_index = tracking_start_index
      end

      private

      attr_reader :weeks, :tracking_start_index

      def title_for(week)
        summary = week.counts.map { |key, count| "#{count} #{key.tr('.', ' ').humanize}" }.join(', ')
        "#{iso_week(week)} (week of #{week.week_start.strftime('%-d %b %Y')}): #{summary.presence || 'no activity'}"
      end

      def iso_week(week)
        week.week_start.strftime('%G-W%V')
      end

      def svg_width
        weeks.size * (CELL_WIDTH + CELL_GAP)
      end

      # Centred in the gap between the week before tracking started and the
      # first tracked week.
      def marker_x
        tracking_start_index * (CELL_WIDTH + CELL_GAP) - CELL_GAP / 2
      end

      def marker_overflow
        (MARKER_HEIGHT - STRIP_HEIGHT) / 2
      end

      def marker_hit_x
        marker_x - MARKER_HIT_WIDTH / 2
      end

      def marker_title
        "Tracking started #{MemberActivityRecorder::TRACKING_STARTED_ON.strftime('%-d %b %Y')}"
      end
    end
  end
end
