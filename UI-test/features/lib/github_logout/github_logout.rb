require 'capybara'

class GitLogout
  include Capybara::DSL

  SIGN_OUT_LINK = 'Sign out' unless const_defined?(:SIGN_OUT_LINK)

  def go_to_github
    visit('https://github.com/')
  end

  def header_github
    find("summary[aria-label='View profile and more']").click
  end

  def click_logout
    find_button(SIGN_OUT_LINK).click
  end
end
