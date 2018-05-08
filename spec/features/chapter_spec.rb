require 'spec_helper'

feature 'viewing a Chapter' do
  it 'a visitor to the website cannot access non active chapters' do
    inactive_chapter = Fabricate(:chapter, active: false)
    visit chapter_path(inactive_chapter.slug)

    expect(page).to have_content('Page not found')
  end

  it 'a visitor to the website cannot access non existing chapter pages' do
    visit chapter_path('test')

    expect(page).to have_content('Page not found')
  end

  it 'renders any upcoming workshops for the chapter' do
    chapter = Fabricate(:chapter)
    workshops = 2.times.map do |n|
      Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.now + 9.days - n.weeks)
    end

    visit chapter_path(chapter.slug)
    workshops.each do |workshop|
      expect(page).to have_content "Workshop at #{workshop.host.name}"
    end
  end

  it 'renders the most recent past workshop for the chapter' do
    chapter = Fabricate(:chapter)
    past_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.today-2.week)
    recent_past_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.today-1.week)

    visit chapter_path(chapter.slug)
    expect(page).to have_content "Workshop at #{recent_past_workshop.host.name}"
    expect(page).to_not have_content "Workshop at #{past_workshop.host.name}"
  end
end
