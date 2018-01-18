require 'capybara/dsl'

class TutorialsPage
  include Capybara::DSL

  def visit_tutorials_page
    visit("http://tutorials.codebar.io/")
  end

  def tutorials_link(link_page)
    click_link(link_page)
  end

end
