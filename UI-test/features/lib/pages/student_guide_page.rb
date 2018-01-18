require 'capybara'
class StudentGuidePage
  include Capybara::DSL

  STUDENT_GUIDE_PAGE_URL = 'http://localhost:3000/student-guide'  unless const_defined?(:STUDENT_GUIDE_PAGE_URL)
  STUDENT_GUIDE_TITLE = 'Student Guide'  unless const_defined?(:STUDENT_GUIDE_TITLE)

  def visit_student_guide_page
    visit(STUDENT_GUIDE_PAGE_URL)
  end

  def find_student_guide_title
    page.find('h2', text: STUDENT_GUIDE_TITLE)
  end




end
