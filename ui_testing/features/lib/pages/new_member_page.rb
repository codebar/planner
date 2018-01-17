require 'capybara/dsl'

class NewMember
  include Capybara::DSL

  def click_sign_up_student
    click_button('I understand and meet the eligibility criteria. Sign me up as a student')
  end

  def click_sign_up_coach
    click_button('Sign up as a coach')
  end
end
