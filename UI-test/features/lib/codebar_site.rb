require_relative './partials/navbar_partial'
require_relative './partials/footer_partial'
require_relative './pages/homepage'

module CodebarSite

  def navbar

  end

  def footer
    FooterPartial.new
  end

  def homepage
    HomePage.new
  end

end
