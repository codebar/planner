require 'capybara/dsl'

class SignedIn
  include Capybara::DSL

  USERNAME_FIELD_ID = "login_field"
  PASSWORD_FIELD_ID = "password"
  AUTHORISE_CODEBAR_ID = "js-oauth-authorize-btn"
  BARCELONA_STUDENT_SUBSCRIPTION_ID = "barcelona-students"
  MENU_TAB_ID = "profile"

  def find_sign_in
    find('a', :text => "Sign in")
  end

  def click_sign_in
    find_sign_in.click
  end

  def find_username_field
    find_field("login")
  end

  def fill_in_sign_in_username
    fill_in(USERNAME_FIELD_ID, :with => "faker321")
  end

  def fill_in_sign_in_password
    fill_in(PASSWORD_FIELD_ID, :with => "test123")
  end

  def click_sign_in_button
    click_button("Sign in")
  end

  def click_london_student_subscription
    # click_on("Subscribe")
    find('#london-students').click
  end

  def click_london_coach_subscription
    find('#london-coaches').click
  end

  def click_edit_button_in_dashboard
    click_link("Edit")
  end

  def get_success_subscription_message
    find('div.alert-box div').text
  end

  def click_menu_tab
    click_link(MENU_TAB_ID)
  end

  def click_sign_out_link
    find('a', :text => "Sign out").click
  end

  def click_dashboard_in_menu_tab
    find('a', :text => "My Dashboard").click
  end

  def click_random_workshop
    find('a', :text => 'Android Development Workshop').click
  end

  def click_attend_workshop_as_student
    find('a', :text => 'Attend as a student').click
  end

  def click_rsvp_workshop_as_student
    find('a', :text => 'RSVP as a student').click
  end

  def click_cancel_my_spot
    accept_alert do
      find('a', :text => 'Cancel my spot').click
    end
  end

  def click_my_profile_on_menu
    find('aside', :text => 'My Profile').click_link('My Profile')
  end

  def click_jobs_on_menu
    find('aside', :text => 'Jobs').click_link('Jobs')
  end

  def click_update_profile
    find('aside', :text => 'My Profile').click_link('Update your details')
  end
end
