require 'capybara'

class SponsorsPage
  include Capybara::DSL

  VISIT_SPONSORS_PAGE = 'http://localhost:3000/sponsors' unless const_defined?(:VISIT_SPONSORS_PAGE)
  HOMEPAGE = 'http://localhost:3000'

  SPONSORS_TITLE = 'Sponsors'


  def visit_hompage_page
    visit(HOMEPAGE)
  end

  def visit_sponsors_page
    visit(VISIT_SPONSORS_PAGE)
  end

  def find_sponsors_title
    page.find('h2', text: SPONSORS_TITLE)
  end
  #
  # def click_teaching_guide_link
  #   click_link(TEACHING_GUIDE_LINK)
  # end




end
