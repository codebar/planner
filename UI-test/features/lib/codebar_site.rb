# pages
require_relative './pages/auth_page'
require_relative './pages/coaches_page'
require_relative './pages/code_of_conduct_page'
require_relative './pages/dashboard_page'
require_relative './pages/events_page'
require_relative './pages/events_someslug_page'
require_relative './pages/github_logout_page'
require_relative './pages/homepage'
require_relative './pages/invitations_page'
require_relative './pages/profile_page'
require_relative './pages/new_job_page'
require_relative './pages/sign_in_page'
require_relative './pages/sign_up_page'
require_relative './pages/sponsors_page'
require_relative './pages/student_guide_page'
require_relative './pages/subscriptions_page'
require_relative './pages/tutorials_index_page'
require_relative './pages/tutorials_page'
require_relative './pages/update_profile_page'
# partials
require_relative './partials/navbar_partial'
require_relative './partials/footer_partial'
require_relative './partials/title_search'


module CodebarSite

  # pages

  def auth_page
      AuthPage.new
  end

  def coaches_page
    CoachesPage.new
  end

  def code_of_conduct_page
    CodeOfConductPage.new
  end

  def dashboard_page
    DashBoardPage.new
  end

  def events_page
    EventsPage.new
  end

  def events_someslug_page
    EventsSomeSlugPage.new
  end

  def github_logout_page
    GithubLogoutPage.new
  end

  def homepage
    HomePage.new
  end

  def invitations_page
    InvitationsPage.new
  end

  def new_job_page
    NewJobPage.new
  end

  def profile_page
    ProfilePage.new
  end

  def sign_in_page
    SignInPage.new
  end

  def sign_up_page
    SignUpPage.new
  end

  def sponsors_page
    SponsorsPage.new
  end

  def student_guide_page
    StudentGuidePage.new
  end

  def tutorials_index_page
    TutorialsIndexPage.new
  end

  def tutorials_page
    TutorialsPage.new
  end

  def subscriptions_page
    SubscriptionsPage.new
  end

  def update_profile_page
    UpdateProfilePage.new
  end

  # partials
  def navbar
    NavbarPartial.new
  end

  def footer
    FooterPartial.new
  end

  def title_search
    TitleSearch.new
  end

end
