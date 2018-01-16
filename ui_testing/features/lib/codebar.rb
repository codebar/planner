# require_relative '../lib/soraia_pages/footer'
# require_relative '../lib/soraia_pages/tutorials_page'


module CodeBar

  def footer
    CodeBarFooter.new
  end

  def tutorials_page
    TutorialsPage.new
  end

end
