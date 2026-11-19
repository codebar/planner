# frozen_string_literal: true

module Admin
  module Stats
    # Renders one metric group's monthly table: one column per month in
    # the active range plus a Totals column. Fed plain dates and
    # Admin::Stats::Monthly::Row objects.
    class TableComponent < ViewComponent::Base
      include ActionView::Helpers::NumberHelper

      def initialize(months:, rows:, caption:) # rubocop:disable Lint/MissingSuper
        @months = months
        @rows = rows
        @caption = caption
      end

      private

      attr_reader :months, :rows, :caption

      def month_header(month)
        month.strftime('%B %Y')
      end

      def cell_value(row, month)
        value = row.cells.fetch(month, 0)
        return number_with_delimiter(value) unless percentage_row?(row)

        "#{number_with_delimiter(value)} (#{percentage_of_total(value, row.total)}%)"
      end

      def percentage_row?(row)
        Admin::Stats::Monthly::RETURNING_LABELS.value?(row.label)
      end

      def percentage_of_total(value, total)
        return 0 if total.zero?

        (value.to_f / total * 100).round
      end

      def total_value(row)
        number_with_delimiter(row.total)
      end
    end
  end
end
