require 'capybara/dsl'

class HomePage
  include Capybara::DSL

  def click_sign_up_student
    click_button('Sign up as a student')
  end

  def click_sign_up_coach
    click_button('Sign up as a coach')
  end

  def click_host_workshop
    click_button('Host a workshop')
  end
end
