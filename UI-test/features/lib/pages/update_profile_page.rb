require 'capybara'

class UpdateProfilePage
  include Capybara::DSL

  SIDEBAR_MENU = 'Menu' unless const_defined?(:SIDEBAR_MENU)
  UPDATE_DETAILS_LINK = 'Update your details' unless const_defined?(:UPDATE_DETAILS_LINK)
  MEMBER_NAME_ID = 'member_name' unless const_defined?(:MEMBER_NAME_ID)
  MEMBER_SURNAME_ID = 'member_surname' unless const_defined?(:MEMBER_SURNAME_ID)
  PROFILE_SAVE_BUTTON = 'Save' unless const_defined?(:PROFILE_SAVE_BUTTON)
  UPDATED_DETAILS_NOTIFICATION = 'Your details have been updated' unless const_defined?(:UPDATED_DETAILS_NOTIFICATION)

  def visit_dashboard
    visit('localhost:3000/dashboard')
  end

  def open_sidebar_menu
    click_link(SIDEBAR_MENU)
  end

  def click_update_details
    click_link(UPDATE_DETAILS_LINK)
  end

  def edit_details_page
    find('h2', text: 'Update your details', exact: true)
    find_field(MEMBER_NAME_ID)
    fill_in(MEMBER_NAME_ID, with: 'NOT JON')
    find_field(MEMBER_SURNAME_ID)
    fill_in(MEMBER_SURNAME_ID, with: 'NOT DON')
  end

  def save_update_profile
    find_button(PROFILE_SAVE_BUTTON).click
  end

  def confirm_details_updated
    find('div', text: UPDATED_DETAILS_NOTIFICATION, exact: true).visible?
  end

end
