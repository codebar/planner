require 'capybara'
class HomePage
  include Capybara::DSL
  HOMEPAGE_URL = 'http://localhost:3000/' unless const_defined?(:HOMEPAGE_URL)
  SIGN_UP_AS_A_STUDENT = 'Sign up as a student' unless const_defined?(:SIGN_UP_AS_A_STUDENT)
  SIGN_UP_AS_A_COACH = 'Sign up as a coach' unless const_defined?(:SIGN_UP_AS_A_COACH)
  SHORT_CODEBAR_DESCRIPTION = 'codebar is a non-profit initiative that facilitates the growth of a diverse tech community by running regular programming workshops.' unless const_defined?(:SHORT_CODEBAR_DESCRIPTION)

  def visit_home_page
    visit(HOMEPAGE_URL)
  end

  def click_sign_up_student
    click_link(SIGN_UP_AS_A_STUDENT)
  end

  def click_sign_up_coach
    click_link(SIGN_UP_AS_A_COACH)
  end

  def find_short_codebar_description
    page.find('p', text: SHORT_CODEBAR_DESCRIPTION)
  end


end
