require_relative './partials/navbar_partial'
require_relative './partials/footer_partial'
require_relative './pages/homepage'
require_relative './pages/code_of_conduct_page'
require_relative './pages/student_guide_page'
require_relative './pages/coaches_page'
require_relative './pages/sponsors_page'
require_relative './pages/events_page'
require_relative './pages/dashboard_page'
require_relative './pages/events_someslug_page'
require_relative './pages/invitations_page'
require_relative './profile_info/signin_page'
require_relative './profile_info/update_profile'
require_relative './jobs/post_a_job'
require_relative './tutorials/tutorials_pages'

module CodebarSite

  # def navbar
  #
  # end
  #
  # def footer
  #   FooterPartial.new
  # end

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

  def job_post
    JobPost.new
  end

  def coaches_page
    CoachesPage.new
  end

  def sponsors_page
    SponsorsPage.new
  end

  def events_page
    EventsPage.new
  end

  def dashboard_page
    DashBoardPage.new
  end

  def events_someslug_page
    EventsSomeSlugPage.new
  end

  def invitations_page
    InvitationsPage.new
  def manage_subs
    ManageSubs.new
  end

  def tutorials
    Tutorials.new
  end

end
