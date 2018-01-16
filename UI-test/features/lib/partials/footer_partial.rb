require 'capybara'

class FooterPartial
  include Capybara::DSL

  CODE_OF_CONDUCT_LINK = 'Code of conduct' unless const_defined?(:CODE_OF_CONDUCT_LINK)

  def visit_homepage
    visit('/')
  end

  # def click_link(name)
  #   click_link(name)
  # end
  #
  # def click_code_of_conduct
  #   click_link(CODE_OF_CONDUCT_LINK)
  # end



  def title_check(name)
    find(:id, name)
  end

end
