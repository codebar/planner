# frozen_string_literal: true

Rails.application.config.after_initialize do
  Prawn::Document.include(Prawn::SVG::Extension)
end
