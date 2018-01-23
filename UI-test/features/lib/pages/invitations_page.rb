require 'capybara'
class InvitationsPage
  include Capybara::DSL

  VISIT_INVITATIONS_PAGE = 'http://localhost:3000/invitations' unless const_defined?(:VISIT_INVITATIONS_PAGE)
  UPCOMING_LINK = 'Upcoming' unless const_defined?(:UPCOMING_LINK)
  ATTENDED_LINK = 'Attended' unless const_defined?(:ATTENDED_LINK)
  WORKSHOPS_ATTENDED_TITLE ='Workshops attended' unless const_defined?(:WORKSHOPS_ATTENDED_TITLE)
  WORKSHOPS_UPCOMING_TITLE ='Upcoming workshops' unless const_defined?(:WORKSHOPS_UPCOMING_TITLE)
  UPCOMING_WORKSHOPS_LINK = 'http://localhost:3000/invitations#upcoming'

  def visit_invitations_page
    visit(VISIT_INVITATIONS_PAGE)
  end

  def click_upcoming
    click_link(UPCOMING_LINK)
  end

  def find_attended_workshops_title
    page.find('h3', text: WORKSHOPS_ATTENDED_TITLE)
  end

  def find_upcoming_workshops_title
    page.find('h3', text: WORKSHOPS_UPCOMING_TITLE)
  end

  def click_attended
    click_link(ATTENDED_LINK)
  end

  def get_upcoming_workshop_link
    UPCOMING_WORKSHOPS_LINK
  end

end
