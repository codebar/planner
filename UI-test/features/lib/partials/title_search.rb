require 'capybara'

class TitleSearch
  include Capybara::DSL




  def title_check(name)
    page.find('div', text: name)
  end

end
