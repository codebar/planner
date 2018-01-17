require 'capybara'
class HomePage
  include Capybara::DSL
  HOMEPAGE_URL = 'http://localhost:3000/'

  def visit_home_page
    visit(HOMEPAGE_URL)
  end

end

x = Homepage.new

x.visit_home_page
