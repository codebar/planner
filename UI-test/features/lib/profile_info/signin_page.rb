require 'capybara'

class SignInPage
  include Capybara::DSL

  SIGN_IN_LINK = 'Sign in' unless const_defined?(:SIGN_IN_LINK)
  GITHUB_USER_ID = 'login_field' unless const_defined?(:GITHUB_USER_ID)
  GITHUB_PSSWRD_ID = 'password' unless const_defined?(:GITHUB_PSSWRD_ID)
  GITHUB_SIGN_IN = 'Sign in' unless const_defined?(:GITHUB_SIGN_IN)

  def visit_homepage
    visit('localhost:3000')
  end

  def sign_in_link
    click_link(SIGN_IN_LINK)
  end

  def enter_github_username
    find_field(GITHUB_USER_ID)
    fill_in(GITHUB_USER_ID, with: 'jdonaldson@spartaglobal.com')
  end

  def enter_github_psswrd
    find_field(GITHUB_PSSWRD_ID)
    fill_in(GITHUB_PSSWRD_ID, with: '93bh64ej')
  end

  def confirm_github_details
    find_button(GITHUB_SIGN_IN).click
  end

  def confirm_redirection_dashboard
    find('h2', text: 'Dashboard', exact: true)
  end

end
