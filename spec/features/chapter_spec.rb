require 'spec_helper'

feature 'viewing a Chapter' do
  let!(:inactive_chapter) { Fabricate(:chapter, active: false) }

  it 'a visitor to the website cannot accses non active chapters' do
    visit chapter_path(inactive_chapter.slug)

    expect(page).to have_content("We can't find the chapter you are looking for")
  end
end
