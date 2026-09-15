# frozen_string_literal: true

module Admin
  # Serves the organisation-wide monthly stats page and its CSV export
  # behind the global-admin check: the admin area also admits organisers,
  # so this controller re-checks admin status itself.
  class StatsController < Admin::ApplicationController
    before_action :authenticate_admin!

    def index
      skip_authorization
      load_stats

      respond_to do |format|
        format.html
        format.csv { send_stats_csv }
      end
    end

    private

    def load_stats
      range_result = resolve_range
      @range_result = range_result
      @months = range_result.months
      @rows = Admin::Stats::Monthly.call(range_result).rows
      @range_start, @range_end = month_inputs(range_result)
    end

    def resolve_range
      range_result = Admin::Stats::Range.resolve(**filter_params)
      return default_range if range_result.invalid? && request.format.csv?
      return page_invalid_range if range_result.invalid?

      session[:admin_stats_months] = range_result.months.map(&:iso8601) unless request.format.csv?
      range_result
    end

    # The page never silently substitutes an invalid range — it
    # re-renders the last valid range (retained in the session) with an
    # inline error. CSV instead falls back to the default 3 months.
    def page_invalid_range
      @range_error = 'The start month must not be after the end month.'
      stored = Array(session[:admin_stats_months]).map { |month| Date.parse(month) }
      return default_range if stored.blank?

      Admin::Stats::Range::Result.new(months: stored, status: :custom,
                                      start_month: stored.first, end_month: stored.last)
    end

    def default_range
      Admin::Stats::Range.resolve
    end

    def filter_params
      return {} unless params.key?(:stats)

      params.expect(stats: %i[preset start_month end_month]).to_h.symbolize_keys
    end

    def month_inputs(range_result)
      [range_result.start_month, range_result.end_month].map { |month| month&.strftime('%Y-%m') }
    end

    def send_stats_csv
      send_data stats_csv, filename: "codebar-stats-#{range_span}.csv",
                           type: 'text/csv', disposition: 'attachment'
    end

    def stats_csv
      CSV.generate do |out|
        out << ['Metric', *@months.map { |month| csv_month(month) }, 'Totals']
        @rows.each { |row| out << csv_row(row) }
      end
    end

    def csv_month(month)
      month.strftime('%Y-%m')
    end

    def csv_row(row)
      [row.label, *@months.map { |month| row.cells.fetch(month, 0) }, row.total]
    end

    def range_span
      "#{csv_month(@months.first)}-#{csv_month(@months.last)}"
    end
  end
end
