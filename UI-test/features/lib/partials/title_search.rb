require 'capybara'

class TitleSearch
  include Capybara::DSL

  def title_check
    if page.has_xpath?('//h1')
      find('h1').text
    elsif page.has_xpath?('//h2')
      find('h2').text
    elsif page.has_xpath?('//h3')
      find('h3').text
    else
      'no title'
    end
  end

end
