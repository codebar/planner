# frozen_string_literal: true

module Admin
  module Members
    class ActivityStripComponent < ViewComponent::Base
      CELL_WIDTH = 8
      CELL_GAP = 4

      def initialize(weeks:)
        super()
        @weeks = weeks
      end

      private

      attr_reader :weeks

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
    end
  end
end
