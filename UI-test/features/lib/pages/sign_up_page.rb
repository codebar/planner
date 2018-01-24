require 'capybara'

class SignUpPage
  include Capybara::DSL

  SIGNUP_URL = 'http://localhost:3000/member/new' unless const_defined?(:SIGNUP_URL)
  CONFIRM_ELIGIBILITY = 'I understand and meet the eligibility criteria. Sign me up as a student' unless const_defined?(:CONFIRM_ELIGIBILITY)
  CREATE_AN_ACCOUNT = 'Create an account'

  def visit_sign_page
    visit(SIGNUP_URL)
  end

  def click_confirm
    click_link(CONFIRM_ELIGIBILITY)
  end

  def click_create_an_account
    click_link(CREATE_AN_ACCOUNT)
  end



end
