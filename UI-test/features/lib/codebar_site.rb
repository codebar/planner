# require_relative './partials/navbar_partial'
# require_relative './partials/footer_partial'
require_relative './logging_in/signin_page'

module CodebarSite

  # def navbar
  #
  # end
  #
  # def footer
  #   FooterPartial.new
  # end

  def signin
    SignInPage.new
  end

end
