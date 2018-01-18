# require_relative './partials/navbar_partial'
# require_relative './partials/footer_partial'
require_relative './profile_info/signin_page'
require_relative './profile_info/update_profile'

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

end
