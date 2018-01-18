require_relative './partials/navbar_partial'
require_relative './partials/footer_partial'
require_relative './pages/homepage'
require_relative './pages/code_of_conduct_page'

module CodebarSite

  def navbar

  end

  def footer
    FooterPartial.new
  end

  def homepage
    HomePage.new
  end

  def code_of_conduct_page
    CodeOfConductPage.new
  end

end
