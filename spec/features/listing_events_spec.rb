RSpec.feature 'event listing', type: :feature do
  describe 'I can see upcoming events' do
    let!(:chapter) { Fabricate(:chapter, active: true) }
    let!(:event) { Fabricate(:event) }

    before do
      Fabricate(:workshop, chapter: chapter)
    end

    scenario 'displays upcoming events page' do
      travel_to(Time.current) do
        visit upcoming_events_path
        expect(page).to have_text 'Upcoming Events'
        expect(page).to have_text event.name
      end
    end
  end

  describe 'I can see past events' do
    let!(:chapter) { Fabricate(:chapter, active: true) }
    let!(:past_event) { Fabricate(:event, date_and_time: 2.weeks.ago) }

    before do
      Fabricate(:workshop, date_and_time: 1.week.ago, chapter: chapter)
    end

    scenario 'displays past events page' do
      travel_to(Time.current) do
        visit past_events_path
        expect(page).to have_text 'Past Events'
        expect(page).to have_text past_event.name
      end
    end
  end

  describe 'root /events redirects to /events/upcoming' do
    scenario 'redirects to upcoming events' do
      visit events_path
      expect(page).to have_text 'Upcoming Events'
      expect(page).to have_current_path '/events/upcoming', ignore_query: true
    end
  end

  context 'pagination' do
    scenario 'past events paginates at 20 per page' do
      travel_to(Time.current) do
        chapter = Fabricate(:chapter, active: true)
        Fabricate.times(22, :event, date_and_time: 2.weeks.ago)
        Fabricate(:workshop, date_and_time: 3.weeks.ago, chapter: chapter)

        visit past_events_path
        expect(page).to have_css('.card', count: 20)
      end
    end

    scenario 'past meetings paginate at 20 per page' do
      travel_to(Time.current) do
        Fabricate.times(22, :meeting, date_and_time: 2.weeks.ago)

        visit past_events_path
        expect(page).to have_css('.card', count: 20)
      end
    end

    scenario 'upcoming meetings paginate at 20 per page' do
      travel_to(Time.current) do
        Fabricate.times(22, :meeting, date_and_time: 2.weeks.from_now)

        visit upcoming_events_path
        expect(page).to have_css('.card', count: 20)
      end
    end
  end
end
