require 'capybara'
class InvitationsPage
  include Capybara::DSL

  VISIT_INVITATIONS_PAGE = 'http://localhost:3000/invitations' unless const_defined?(:VISIT_INVITATIONS_PAGE)
  UPCOMING_LINK = 'Upcoming' unless const_defined?(:UPCOMING_LINK)
  ATTENDED_LINK = 'Attended' unless const_defined?(:ATTENDED_LINK)

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
