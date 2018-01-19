require 'capybara'

class TutorialsIndexPage
  include Capybara::DSL

  def click_tutorial_link(name)
    click_link(name)
  end


end
