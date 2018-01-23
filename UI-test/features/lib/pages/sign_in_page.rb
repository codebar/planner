require 'capybara'

class SignInPage
  include Capybara::DSL

  SIGN_IN_LINK = 'Sign in' unless const_defined?(:SIGN_IN_LINK)
  GITHUB_USER_ID = 'login_field' unless const_defined?(:GITHUB_USER_ID)
  GITHUB_PSSWRD_ID = 'password' unless const_defined?(:GITHUB_PSSWRD_ID)
  GITHUB_SIGN_IN = 'Sign in' unless const_defined?(:GITHUB_SIGN_IN)
  SIDEBAR_MENU = 'Menu' unless const_defined?(:SIDEBAR_MENU)
  SIGN_OUT_LINK = 'Sign out' unless const_defined?(:SIGN_OUT_LINK)
  SIGN_IN_PAGE = 'https://github.com/login?client_id=07d1fce8251a1b91a6bc&return_to=%2Flogin%2Foauth%2Fauthorize%3Fclient_id%3D07d1fce8251a1b91a6bc%26redirect_uri%3Dhttp%253A%252F%252Fcodebar.io%252Fauth%252Fgithub%252Fcallback%26response_type%3Dcode%26scope%3Duser%253Aemail%26state%3D03669bb9bfc1971012fdbbc7bd1a34c4b62d24ba4b2d71a1'

  def sign_in_link
    click_link(SIGN_IN_LINK)
  end

  def sign_in_page_link
    SIGN_IN_PAGE
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

  def sign_in_func
    sign_in_link
    enter_github_username
    enter_github_psswrd
    confirm_github_details
    confirm_redirection_dashboard
  end

  def sign_out_func
    open_sidebar_menu
    sign_out
  end

end
