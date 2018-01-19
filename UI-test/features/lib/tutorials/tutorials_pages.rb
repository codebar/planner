require 'capybara'

class Tutorials
  include Capybara::DSL

  TUTORIALS_LINK = 'Tutorials' unless const_defined?(:TUTORIALS_LINK)
  CSS_LESSON_LINK = 'Lesson 4 - CSS, layouts and formatting' unless const_defined?(:CSS_LESSON_LINK)
  BACK_TO_TUTORIALS_LINK = 'Back to tutorials' unless const_defined?(:BACK_TO_TUTORIALS_LINK)
  BACK_TO_HOME = 'codebar mainpage' unless const_defined?(:BACK_TO_HOME)

  def go_to_tutorials
    click_link(TUTORIALS_LINK)
  end

  def go_to_css
    click_link(CSS_LESSON_LINK)
  end

  def go_back
    click_link(BACK_TO_TUTORIALS_LINK)
  end

  def go_home
    click_link(BACK_TO_HOME)
  end

end
