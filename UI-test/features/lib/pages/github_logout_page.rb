require 'capybara'

class GithubLogoutPage
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

  def github_logout_func
    go_to_github
    header_github
    click_logout
  end

  def github_logout_if_possible
    go_to_github
    if page.has_xpath?('//*[@id="user-links"]/li[3]/details/summary/img')
      github_logout_func
    end
  end

end
