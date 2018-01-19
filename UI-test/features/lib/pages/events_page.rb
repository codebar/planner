require 'capybara'

class EventsPage
  include Capybara::DSL

  VISIT_EVENTS_PAGE = 'http://localhost:3000/events' unless const_defined?(:VISIT_EVENTS_PAGE)
  EVENTS_LINK = 'Event' unless const_defined?(:EVENTS_LINK)


  def visit_events_page
    visit(VISIT_EVENTS_PAGE)
  end

  def click_events_link
    click_link(EVENTS_LINK)
  end

end
