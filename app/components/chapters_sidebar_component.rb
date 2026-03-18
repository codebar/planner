# frozen_string_literal: true

class ChaptersSidebarComponent < ViewComponent::Base
  # ViewComponent::Base does not define initialize, so super is not needed
  def initialize(chapters:, title: nil) # rubocop:disable Lint/MissingSuper
    @chapters = chapters
    @title = title
  end

  private

  attr_reader :chapters, :title
end
