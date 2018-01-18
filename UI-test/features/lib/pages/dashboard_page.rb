require 'capybara'
class DashBoardPage
  include Capybara::DSL

  SIDEBAR = '#sidebar' unless const_defined?(:SIDEBAR)
  VISIT_DASHBOARD_PAGE = 'http://localhost:3000/dashboard'

  def visit_dashboard_page
    visit(VISIT_DASHBOARD_PAGE)
  end

  def find_sidebar
    find(SIDEBAR)
  end

  def click_name_link
    sideBarDiv = find_sidebar
    sideBarDiv.find('a').click
  end


end
