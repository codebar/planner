require 'capybara'

class SignInPage
  include Capybara::DSL

  SIGN_IN_LINK = 'Sign in' unless const_defined?(:SIGN_IN_LINK)
  GITHUB_USER_ID = 'login_field' unless const_defined?(:GITHUB_USER_ID)
  GITHUB_PSSWRD_ID = 'password' unless const_defined?(:GITHUB_PSSWRD_ID)
  GITHUB_SIGN_IN = 'Sign in' unless const_defined?(:GITHUB_SIGN_IN)
  SIDEBAR_MENU = 'Menu' unless const_defined?(:SIDEBAR_MENU)
  SIGN_OUT_LINK = 'Sign out' unless const_defined?(:SIGN_OUT_LINK)

  def visit_homepage
    visit('localhost:3000')
  end

  def sign_in_link
    click_link(SIGN_IN_LINK)
  end

  def enter_github_username
    find_field(GITHUB_USER_ID)
    fill_in(GITHUB_USER_ID, with: 'youngjeezy')
  end

  def enter_github_psswrd
    find_field(GITHUB_PSSWRD_ID)
    fill_in(GITHUB_PSSWRD_ID, with: 'abc4567')
  end

  def confirm_github_details
    find_button(GITHUB_SIGN_IN).click
  end

  def confirm_redirection_dashboard
    find('h2', text: 'Dashboard', exact: true)
  end

  def open_sidebar_menu
    click_link(SIDEBAR_MENU)
  end

  def sign_out
    click_link(SIGN_OUT_LINK)
  end

end
