require 'capybara'

class CoachesPage
  include Capybara::DSL

  VISIT_COACHES_PAGE = 'http://localhost:3000/coaches' unless const_defined?(:VISIT_COACHES_PAGE)

  COACHES_TITLE = 'Coaches'  unless const_defined?(:COACHES_TITLE)

  TEACHING_GUIDE_LINK = 'teaching guide' unless const_defined?(:TEACHING_GUIDE_LINK)

  def visit_coaches_page
    visit(VISIT_COACHES_PAGE)
  end

  def find_coaches_title
    page.find('h2', text: COACHES_TITLE)
  end

  def click_teaching_guide_link
    click_link(TEACHING_GUIDE_LINK)
  end




end
