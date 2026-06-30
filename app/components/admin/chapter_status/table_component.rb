# frozen_string_literal: true

class Admin::ChapterStatus::TableComponent < ViewComponent::Base
  def initialize(label:, rows:, months:, at_risk_ids: nil) # rubocop:disable Lint/MissingSuper
    @label = label
    @rows = rows
    @months = months
    @at_risk_ids = at_risk_ids
  end

  private

  attr_reader :label, :rows, :months, :at_risk_ids
end
