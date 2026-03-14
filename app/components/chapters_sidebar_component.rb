# frozen_string_literal: true

class ChaptersSidebarComponent < ViewComponent::Base
  def initialize(chapters:, title: nil)
    super()
    @chapters = chapters
    @title = title
  end

  private

  attr_reader :chapters, :title
end
