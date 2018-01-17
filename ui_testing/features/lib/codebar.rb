require_relative '../lib/pages/footer'
# require_relative '../lib/pages/tutorials_page'
require_relative '../lib/pages/codebar_homepage'

module CodeBar

  def codebar_homepage
    HomePage.new
  end
  
  def footer
    CodeBarFooter.new
  end

  def tutorials_page
    TutorialsPage.new
  end

end
