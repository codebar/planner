require_relative './partials/navbar_partial'
require_relative './partials/footer_partial'
require_relative './partials/title_search'

module CodebarSite

  def navbar

  end

  def footer
    FooterPartial.new
  end

  def title_search
    TitleSearch.new
  end

end
