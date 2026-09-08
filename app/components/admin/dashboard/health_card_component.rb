# frozen_string_literal: true

module Admin
  module Dashboard
    # The Chapter Health card on /admin/chapters/:id: status badge, workshop
    # recency and countdown, median cadence, eligible members, organisers.
    # Yield the timeline (or anything else) into the card body via content.
    class HealthCardComponent < ViewComponent::Base
      BUCKET_CLASSES = { inactive: 'bg-secondary', dormant: 'bg-warning text-dark',
                         active: 'bg-success' }.freeze

      def initialize(health:) # rubocop:disable Lint/MissingSuper
        @health = health
      end

      private

      attr_reader :health

      def bucket_badge_class = BUCKET_CLASSES.fetch(health.bucket)

      def tile(label, value, title: nil)
        { label:, value:, title: }
      end

      def tiles
        [
          tile('Status', health.bucket),
          tile('Previous workshop', previous_workshop_value, title: previous_workshop_title),
          tile('Next workshop', next_workshop_value),
          tile('Cadence (days, median, 180d)', cadence_value),
          tile('Eligible members', eligible_members_value),
          tile('Organisers', number_value(health.organiser_count))
        ]
      end

      def previous_workshop_value
        health.days_since_last_workshop ? "#{number_value(health.days_since_last_workshop)} days ago" : 'never'
      end

      def previous_workshop_title
        health.last_workshop_date&.to_date&.to_fs(:long)
      end

      def next_workshop_value
        health.days_until_next_workshop ? "#{number_value(health.days_until_next_workshop)} days away" : 'none'
      end

      def cadence_value
        health.median_cadence_days ? number_value(health.median_cadence_days) : '—'
      end

      def eligible_members_value
        number_value(health.eligible_students + health.eligible_coaches)
      end

      def number_value(value)
        number_with_delimiter(value)
      end
    end
  end
end
