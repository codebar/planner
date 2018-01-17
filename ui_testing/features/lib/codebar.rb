require_relative '../lib/pages/footer'
require_relative '../lib/pages/tutorials_page'
require_relative '../lib/pages/navbar'
require_relative '../lib/pages/homepage'
require_relative '../lib/pages/new_member_page'
require_relative '../lib/pages/student_details_page'
require_relative '../lib/pages/socialmedia'

module CodeBar

  def navbar
    NavBar.new
  end

  def homepage
    HomePage.new
  end

  def footer
    CodeBarFooter.new
  end

  def tutorials_page
    TutorialsPage.new
  end

  def newmember
    NewMember.new
  end

  def student_details
    Student.new
  end

end
