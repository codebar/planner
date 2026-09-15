# frozen_string_literal: true

module Admin
  module Stats
    # Resolves a stats date range into a list of complete calendar months
    # (first-of-month Dates) in the app time zone. Presets anchor at the
    # last complete month; the current partial month never appears. A
    # start month after the end month is an explicit invalid state — the
    # caller picks the response (page: inline error, CSV: default range).
    class Range
      Result = Data.define(:months, :status, :start_month, :end_month) do
        def invalid?
          status == :invalid
        end
      end

      PRESETS = { '3' => 3, '6' => 6, '12' => 12 }.freeze

      # Server-side bound on custom ranges: wider spans route to the
      # invalid state, reusing the inline-error and CSV-fallback paths.
      # session-stored range well inside the cookie store and the table
      # readable (20 years).
      MAX_SPAN_MONTHS = 240

      class << self
        def resolve(preset: nil, start_month: nil, end_month: nil)
          start = parse_month(start_month)
          finish = parse_month(end_month)

          return custom_result(start, finish) if start && finish

          default_result(span_for(preset))
        end

        private

        def span_for(preset)
          PRESETS[preset.to_s] || 3
        end

        def current_month
          Time.zone.today.beginning_of_month
        end

        def last_complete_month
          current_month.prev_month
        end

        def parse_month(value)
          return nil if value.blank?

          Date.strptime(value.to_s, '%Y-%m').beginning_of_month
        rescue ArgumentError, TypeError
          nil
        end

        def custom_result(start, finish)
          finish = last_complete_month if finish >= current_month
          return invalid_result(start, finish) if start > finish
          return invalid_result(start, finish) if span_months(start, finish) > MAX_SPAN_MONTHS

          Result.new(months: month_list(start, finish), status: :custom,
                     start_month: start, end_month: finish)
        end

        def invalid_result(start, finish)
          Result.new(months: [], status: :invalid, start_month: start, end_month: finish)
        end

        def default_result(count)
          last = last_complete_month
          months = Array.new(count) { |i| last << (count - 1 - i) }
          Result.new(months:, status: :default, start_month: nil, end_month: nil)
        end

        def month_list(from, to)
          span = span_months(from, to)
          (0..span).map { |offset| from >> offset }
        end

        def span_months(from, to)
          (to.year * 12 + to.month) - (from.year * 12 + from.month)
        end
      end
    end
  end
end
