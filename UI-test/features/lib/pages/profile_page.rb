require 'capybara'

class ProfilePage
  include Capybara::DSL

  VISIT_PROFILE_PAGE = 'http://localhost:3000/profile' unless const_defined?(:VISIT_PROFILE_PAGE)
  PROFILE_TITLE = 'My Profile' unless const_defined?(:PROFILE_TITLE)
  UPDATE_DETAILS_LINK = 'Update your details' unless const_defined?(:UPDATE_DETAILS_LINK)

  def visit_profile_page
    visit(VISIT_PROFILE_PAGE)
  end

  def find_profile_title
    page.find('h2', text: PROFILE_TITLE)
  end

  def click_update_details
    click_link(UPDATE_DETAILS_LINK)
  end


end
