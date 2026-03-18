require 'rails_helper'
require 'view_component/test_helpers'

RSpec.describe ChaptersSidebarComponent do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:chapters) { Fabricate.times(3, :chapter) }

  it 'renders chapter names as links' do
    render_inline ChaptersSidebarComponent.new(chapters: chapters)

    chapters.each do |chapter|
      expect(page).to have_link(chapter.name, href: chapter_path(chapter.slug))
    end
  end

  it 'renders nothing when no chapters' do
    render_inline ChaptersSidebarComponent.new(chapters: [])

    expect(page).to have_css('ul.list-unstyled.ms-0', visible: true)
    expect(page).to have_no_css('li')
  end
end
