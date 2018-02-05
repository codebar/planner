require 'capybara'
class CodeOfConductPage
  include Capybara::DSL
  CODE_OF_CONDUCT_URL = 'http://localhost:3000/code-of-conduct' unless const_defined?(:CODE_OF_CONDUCT_URL)

  CODE_OF_CONDUCT_TITLE = 'Code of conduct' unless const_defined?(:CODE_OF_CONDUCT_TITLE)


  def visit_code_of_conduct_page
    visit(CODE_OF_CONDUCT_URL)
  end

  def find_code_of_conduct_title
    page.find('h2', text: CODE_OF_CONDUCT_TITLE)
  end


end
