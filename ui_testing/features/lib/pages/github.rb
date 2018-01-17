require 'capybara/dsl'

class GitHub
  include Capybara::DSL

  GITHUB_URL = 'https://github.com/'
  USERNAME_FORM_ID = 'login_field'
  PASSWORD_FORM_ID = 'password'
  SIGN_IN_TEXT = 'Sign in'

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
    find('summary[aria-label="View profile and more"]').click
  end

  def click_sign_out
    click_button('Sign out')
  end

  def visit_github
    visit(GITHUB_URL)
  end

  def find_developer_text
    find('h1', text: 'Built for developers')
  end
end
