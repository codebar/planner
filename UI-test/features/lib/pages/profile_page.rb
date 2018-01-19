require 'capybara'

class ProfilePage
  include Capybara::DSL

  VISIT_PROFILE_PAGE = 'http://localhost:3000/profile' unless const_defined?(:VISIT_PROFILE_PAGE)
  PROFILE_TITLE = 'My Profile'

  def visit_profile_page
    visit(VISIT_PROFILE_PAGE)
  end

  def find_profile_title
    page.find('h2', text: PROFILE_TITLE)
  end


end
