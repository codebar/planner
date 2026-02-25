RSpec.feature 'event listing', type: :feature do
  describe 'I can see upcoming events' do
    let!(:chapter) { Fabricate(:chapter, active: true) }
    let!(:upcoming_workshop) { Fabricate(:workshop, chapter: chapter) }
    let!(:event) { Fabricate(:event) }

    scenario 'displays upcoming events page' do
      visit upcoming_events_path
      expect(page).to have_content 'Upcoming Events'
      expect(page).to have_content event.name
    end
  end

  describe 'I can see past events' do
    let!(:chapter) { Fabricate(:chapter, active: true) }
    let!(:past_event) { Fabricate(:event, date_and_time: Time.zone.now - 2.weeks) }
    let!(:past_workshop) { Fabricate(:workshop, date_and_time: Time.zone.now - 1.week, chapter: chapter) }

    scenario 'displays past events page' do
      visit past_events_path
      expect(page).to have_content 'Past Events'
      expect(page).to have_content past_event.name
    end
  end

  describe 'root /events redirects to /events/upcoming' do
    scenario 'redirects to upcoming events' do
      visit events_path
      expect(page).to have_content 'Upcoming Events'
      expect(page).to have_current_path '/events/upcoming', ignore_query: true
    end
  end

  context 'pagination' do
    scenario 'past events paginates at 20 per page' do
      chapter = Fabricate(:chapter, active: true)
      Fabricate.times(22, :event, date_and_time: 2.weeks.ago)
      Fabricate(:workshop, date_and_time: 3.weeks.ago, chapter: chapter)

      visit past_events_path
      expect(page).to have_selector('.card', count: 20)
    end
  end
end
