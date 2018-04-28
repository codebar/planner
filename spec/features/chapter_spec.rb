require 'spec_helper'

feature 'viewing a Chapter' do
  let!(:inactive_chapter) { Fabricate(:chapter, active: false) }

  it 'a visitor to the website cannot access non active chapters' do
    visit chapter_path(inactive_chapter.slug)

    expect(page).to have_content('Page not found')
  end

  it 'a visitor to the website cannot access non existing chapter pages' do
    visit chapter_path('test')

    expect(page).to have_content('Page not found')
  end
end
