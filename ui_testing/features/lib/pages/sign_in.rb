require 'capybara/dsl'

class SignedIn
  include Capybara::DSL

  USERNAME_FIELD_ID = "login_field"
  PASSWORD_FIELD_ID = "password"

  def find_sign_in
    find('a', :text => "Sign in")
  end

  def click_sign_in
    find_sign_in.click
  end

  def fill_in_sign_in_username
    fill_in(USERNAME_FIELD_ID, :with => "nnoor@spartaglobal.com")
  end

  def fill_in_sign_in_password
    fill_in(PASSWORD_FIELD_ID, :with => "iPhone73")
  end

  def click_sign_in_button
    click_button("Sign in")
  end

  def find_edit_button_in_dashboard
    find('a', :text => "Edit")
  end

  def click_edit_button_in_dashboard
    find_edit_button_in_dashboard.click
  end



end
