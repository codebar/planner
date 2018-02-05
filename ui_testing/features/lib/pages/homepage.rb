require 'capybara/dsl'

class HomePage
  include Capybara::DSL

  STUDENT_TEXT = 'Sign up as a student'
  COACH_TEXT = 'Sign up as a coach'
  WORKSHOP_TEXT = 'Host a workshop'

  def click_sign_up_student
    click_link(STUDENT_TEXT)
  end

  def click_sign_up_coach
    click_link(COACH_TEXT)
  end

  def click_host_workshop
    click_link(WORKSHOP_TEXT)
  end

  def check_mail_app
    value = %x(ps aux)
    value
  end
end
