require 'capybara/dsl'

class HomePage
  include Capybara::DSL

  def visit_home_page
    visit('/')
  end

  def find_codebar_logo
    find(:xpath, ".//a[@href='/']")
  end

  def click_codebar_logo
    find_codebar_logo.click
  end
end
