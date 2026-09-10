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
        number_with_delimiter(row.cells.fetch(month, 0))
      end

      def total_value(row)
        number_with_delimiter(row.total)
      end
    end
  end
end
