require 'capybara/dsl'

class GitHub
  include Capybara::DSL

  GITHUB_URL = 'https://github.com/'
  USERNAME_FORM_ID = 'login_field'
  PASSWORD_FORM_ID = 'password'
  SIGN_IN_TEXT = 'Sign in'
  AUTHORIZATION_BTN_ID = 'js-oauth-authorize-btn'
  PROFILE_ICON = 'summary[aria-label="View profile and more"]'
  SIGN_OUT_TEXT = 'Sign out'
  DEVELOPER_TEXT = 'Built for developers'

  def fill_username(username)
    fill_in(USERNAME_FORM_ID, :with => username)
  end

  def fill_password(password)
    fill_in(PASSWORD_FORM_ID, :with => password)
  end

  def click_submit
    click_button(SIGN_IN_TEXT)
  end

  def click_profile_icon
    find(PROFILE_ICON).click
  end

  def click_sign_out
    click_button(SIGN_OUT_TEXT)
  end

  def visit_github
    visit(GITHUB_URL)
  end

  def find_developer_text
    find('h1', text: DEVELOPER_TEXT)
  end

  def find_authorization
    has_button?(AUTHORIZATION_BTN_ID)
  end

  def click_authorization
    click_button(AUTHORIZATION_BTN_ID)
  end
end
