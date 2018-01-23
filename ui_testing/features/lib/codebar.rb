require_relative '../lib/pages/footer'
require_relative '../lib/pages/tutorials_page'
require_relative '../lib/pages/navbar'
require_relative '../lib/pages/homepage'
require_relative '../lib/pages/new_member_page'
require_relative '../lib/pages/github'
require_relative '../lib/pages/socialmedia'
require_relative '../lib/pages/sign_in'
require_relative '../lib/pages/donate_page'

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

  def github
    GitHub.new
  end

  def sign_in_page
    SignedIn.new
  end

  def donation
    DonatePage.new
  end

  def update_profile
    UpdateProfile.new
  end
end
