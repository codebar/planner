require_relative './partials/navbar_partial'
require_relative './partials/footer_partial'
require_relative './partials/title_search'
require_relative './pages/homepage'
require_relative './pages/code_of_conduct_page'
require_relative './pages/student_guide_page'
require_relative './pages/tutorials_page'
require_relative './profile_info/signin_page'
require_relative './profile_info/update_profile'

module CodebarSite

  def navbar
    NavbarPartial.new
  end

  def footer
    FooterPartial.new
  end

  def title_search
    TitleSearch.new
  end

  def sign_in
    SignInPage.new
  end

  def update_profile
    UpdateProfile.new
  end

  def github_controller
    GitLogout.new
  end

  def homepage
    HomePage.new
  end

  def code_of_conduct_page
    CodeOfConductPage.new
  end

  def student_guide_page
    StudentGuidePage.new
  end

  def tutorials
    TutorialsPage.new
  end

end
