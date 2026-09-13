# frozen_string_literal: true

module Admin
  module Members
    # Buckets a member's activity log into the 52 ISO weeks ending the current week.
    # Sole owner of strip state classification; the component renders, never classifies.
    class ActivityStrip
      WEEK_COUNT = 52
      LOGIN_ONLY_KEYS = %w[member.login member.logout].freeze

      Row = Struct.new(:week_start, :state, :counts, keyword_init: true)

      def initialize(member, now: Time.zone.now)
        @member = member
        @now = now
      end

      def rows # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        activities = PublicActivity::Activity
                     .where(owner: @member)
                     .where(created_at: window_start..@now)
                     .order(:created_at)

        grouped = activities.group_by { |a| a.created_at.to_date.beginning_of_week.beginning_of_day }

        weeks.map do |week_start|
          week_activities = grouped[week_start] || []
          counts = week_activities.map(&:key).tally
          state = classify(counts)

          Row.new(week_start:, state:, counts:)
        end
      end

      private

      def classify(counts)
        return :empty if counts.empty?
        return :login_only if counts.keys.all? { |key| LOGIN_ONLY_KEYS.include?(key) }

        :active
      end

      def weeks
        @weeks ||= Array.new(WEEK_COUNT) { |i| current_week_start - (WEEK_COUNT - 1 - i).weeks }
      end

      def window_start
        @window_start ||= current_week_start - (WEEK_COUNT - 1).weeks
      end

      def current_week_start
        @current_week_start ||= @now.to_date.beginning_of_week.beginning_of_day
      end
    end
  end
end
