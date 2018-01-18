require 'capybara'
class DashBoardPage
  include Capybara::DSL

  SIDEBAR = '#sidebar' unless const_defined?(:SIDEBAR)
  VISIT_DASHBOARD_PAGE = 'http://localhost:3000/dashboard' unless const_defined?(:VISIT_DASHBOARD_PAGE)
  DASHBOARD_TITLE = 'Dashboard' unless const_defined?(:DASHBOARD_TITLE)
  COURSE_LINK = 'Course' unless const_defined?(:COURSE_LINK)
  MEETING_LINK = 'Meeting' unless const_defined?(:MEETING_LINK)
  EVENT_LINK = 'Event' unless const_defined?(:EVENT_LINK)

  def visit_dashboard_page
    visit(VISIT_DASHBOARD_PAGE)
  end

  def find_dashboard_title
    page.find('h2', text: DASHBOARD_TITLE)
  end

  def find_sidebar
    find(SIDEBAR)
  end

  def click_name_link
    sideBarDiv = find_sidebar
    sideBarDiv.find('a').click
  end

  def click_course
    click_link(COURSE_LINK)
  end

  def click_meeting
    click_link(MEETING_LINK)
  end

  def click_event
    click_link(EVENT_LINK)
  end




end
