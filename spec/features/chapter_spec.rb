require 'spec_helper'

feature 'viewing a Chapter' do
  context 'non active chapters' do
    let(:inactive_chapter) { Fabricate(:chapter, active: false) }

    it 'a visitor to the website cannot access non active chapters' do
      visit chapter_path(inactive_chapter.slug)

      expect(page).to have_content('Page not found')
    end

    it 'a visitor to the website can access inactive chapter events' do
      past_workshop = Fabricate(:workshop, chapter: inactive_chapter, date_and_time: Time.zone.today - 2.week)

      visit workshop_path(past_workshop)

      expect(page).to have_content "Workshop at #{past_workshop.host.name}"
    end
  end

  context 'active chapters' do
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
      past_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.today - 2.week)
      recent_past_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.today - 1.week)

      visit chapter_path(chapter.slug)
      expect(page).to have_content "Workshop at #{recent_past_workshop.host.name}"
      expect(page).to_not have_content "Workshop at #{past_workshop.host.name}"
    end
    
    it 'renders the 6 most recent sponsors for the chapter' do
      chapter = Fabricate(:chapter)
      workshops = 6.times.map do |n|
        Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.now - n.weeks)
      end

      visit chapter_path(chapter.slug)
      workshops.each do |workshop|
        expect(page).to have_link(workshop.sponsors.name)
      end
    end
  end
end
