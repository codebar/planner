RSpec.feature 'viewing a Chapter', type: :feature do
  context 'non active chapters' do
    let(:inactive_chapter) { Fabricate(:chapter, active: false) }

    it 'a visitor to the website cannot access non active chapters' do
      visit chapter_path(inactive_chapter.slug)

      expect(page).to have_content('Page not found')
    end

    it 'a visitor to the website can access inactive chapter events' do
      travel_to(Time.current) do
        past_workshop = Fabricate(:workshop, chapter: inactive_chapter, date_and_time: 2.weeks.ago)

        visit workshop_path(past_workshop)

        expect(page).to have_content "Workshop at #{past_workshop.host.name}"
      end
    end
  end

  context 'active chapters' do
    it 'a visitor to the website cannot access non existing chapter pages' do
      visit chapter_path('test')

      expect(page).to have_content('Page not found')
    end

    it 'renders chapter without organisers' do
      chapter = Fabricate(:chapter_without_organisers, name: 'Empty Chapter')
      expect(chapter.organisers.size).to eq 0

      visit chapter_path(chapter.slug)

      expect(page).to have_content 'Empty Chapter'
      expect(page).not_to have_content 'Team'
    end

    it 'renders any upcoming workshops for the chapter' do
      travel_to(Time.current) do
        chapter = Fabricate(:chapter)
        workshops = 2.times.map do |n|
          Fabricate(:workshop, chapter: chapter, date_and_time: 9.days.from_now - n.weeks)
        end

        visit chapter_path(chapter.slug)
        workshops.each do |workshop|
          expect(page).to have_content "Workshop at #{workshop.host.name}"
        end
      end
    end

    it 'renders any upcoming events for the chapter' do
      travel_to(Time.current) do
        chapter = Fabricate(:chapter)
        2.times.map do |n|
          Fabricate(:event, name: "Event #{n + 1}",
                            chapters: [chapter],
                            date_and_time: 2.months.from_now - n.months)
        end

        visit chapter_path(chapter.slug)
        expect(page).to have_content 'Event 1'
        expect(page).to have_content 'Event 2'
      end
    end

    it 'renders the most recent past workshop for the chapter' do
      travel_to(Time.current) do
        chapter = Fabricate(:chapter)
        past_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: 2.weeks.ago)
        recent_past_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: 1.week.ago)

        visit chapter_path(chapter.slug)
        expect(page).to have_content "Workshop at #{recent_past_workshop.host.name}"
        expect(page).not_to have_content "Workshop at #{past_workshop.host.name}"
      end
    end

    it 'renders the 6 most recent sponsors for the chapter' do
      travel_to(Time.current) do
        chapter = Fabricate(:chapter)
        workshops = 2.times.map do |n|
          Fabricate(:workshop, chapter: chapter, date_and_time: n.weeks.ago)
        end

        visit chapter_path(chapter.slug)
        workshops.each do |workshop|
          expect(page).to have_link(workshop.sponsors.name)
        end
      end
    end
  end
end
