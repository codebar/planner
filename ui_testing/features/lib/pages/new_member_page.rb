require 'capybara/dsl'

class NewMember
  include Capybara::DSL

  def click_sign_up_student
    click_link('I understand and meet the eligibility criteria. Sign me up as a student')
  end

  def click_sign_up_coach
    click_link('Sign up as a coach')
  end

  def find_dashboard
    find('h2', text: 'Dashboard')
  end

  def find_profile
    find_link('Menu')
  end
end
