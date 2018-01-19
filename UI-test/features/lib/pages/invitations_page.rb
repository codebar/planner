require 'capybara'
class InvitationsPage
  include Capybara::DSL

  VISIT_INVITATIONS_PAGE = 'http://localhost:3000/invitations'
  UPCOMING_LINK = 'Upcoming'
  ATTENDED_LINK = 'Attended'

  def visit_invitations_page
    visit(VISIT_INVITATIONS_PAGE)
  end

  def click_upcoming
    click_link(UPCOMING_LINK)
  end

  def click_attended
    click_link(ATTENDED_LINK)
  end

end
