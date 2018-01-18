require 'capybara'

class TitleSearch
  include Capybara::DSL




  def title_check(name)
    if page.find('h1', text: name) == ''
      page.find('h2', text: name)
    else
      page.find('h1', text: name)      
    end
  end

end
