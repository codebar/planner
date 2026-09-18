require 'rails_helper'

RSpec.describe 'events/_event_actions.html.haml' do
  let(:event) { Fabricate(:event) }

  before do
    assign(:event, EventPresenter.new(event))
    allow(view).to receive(:logged_in?).and_return(true)
  end

  it 'renders the RSVP buttons when RSVPs are open' do
    render

    expect(rendered).to have_link(t('events.attend_as_student'))
    expect(rendered).to have_link(t('events.attend_as_coach'))
  end

  context 'when RSVPs have closed' do
    let(:event) { Fabricate(:event, date_and_time: 2.hours.from_now) }

    it 'shows the closed badge and hides the RSVP buttons' do
      render

      expect(rendered).to include(t('events.rsvps_closed'))
      expect(rendered).to have_no_link(t('events.attend_as_student'))
      expect(rendered).to have_no_link(t('events.attend_as_coach'))
    end
  end
end
