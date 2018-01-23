require 'capybara'

class AuthPage
  include Capybara::DSL

  AUTH_BUTTON_ID = 'js-oauth-authorize-btn'

  def auth_check
    if page.has_xpath?('//*[@id="js-pjax-container"]/div/div[1]/h2')
      find_button(AUTH_BUTTON_ID).click
    end
  end

end
