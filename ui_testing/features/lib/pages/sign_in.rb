require 'capybara/dsl'

class SignedIn
  include Capybara::DSL

  USERNAME_FIELD_ID = "login_field"
  PASSWORD_FIELD_ID = "password"
  AUTHORISE_CODEBAR_ID = "js-oauth-authorize-btn"
  BARCELONA_STUDENT_SUBSCRIPTION_ID = "barcelona-students"
  MENU_TAB_ID = "profile"
  JOB_TITLE_ID = "job_title"
  COMPANY_ID = 'job_company'
  LOCATION_ID = 'job_location'
  DESCRIPTION_ID = 'job_description'
  JOB_LINK_ID = 'job_link_to_job'
  SUBMIT_FIELD_POST_JOB = 'Submit job'


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
    find('#brighton-students').click
  end

  def click_london_coach_subscription
    find('#brighton-coaches').click
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

  def click_post_a_job
    find('a', :text => 'List a job').click
  end

  def fill_in_job_title_field
    fill_in(JOB_TITLE_ID, :with => "Test1")
  end

  def fill_in_company_field
    fill_in(COMPANY_ID, :with => "Test2")
  end

  def fill_in_location_field
    fill_in(LOCATION_ID, :with => "Test")
  end

  def fill_in_description_field
    fill_in(DESCRIPTION_ID, :with => "This is a description of the test")
  end

  def fill_in_link_to_field
    fill_in(JOB_LINK_ID, :with => "http://www.google.com")
  end

  def click_submit_to_post_job
    click_button(SUBMIT_FIELD_POST_JOB)
  end

  def check_post_title
    find('div.large-12 h1').text
  end
  
  def click_jobs_on_menu
    find('aside', :text => 'Jobs').click_link('Jobs')
  end

  def click_update_profile
    find('aside', :text => 'My Profile').click_link('Update your details')
  end
  
  def click_my_profile_on_menu
    find('aside', :text => 'My Profile').click_link('My Profile')
  end
end
