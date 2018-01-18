require 'capybara'

class FooterPartial
  include Capybara::DSL

  CODE_OF_CONDUCT_LINK = 'Code of conduct' unless const_defined?(:CODE_OF_CONDUCT_LINK)

  def visit_homepage
    visit('/')
  end

  def click_chosen_link(name)
    if name == 'facebook'
      find(:css, 'i.fa.fa-facebook.fa-stack-1x.fa-inverse').click
    elsif name == 'github'
      find(:css, 'i.fa.fa-slack.fa-stack-1x.fa-inverse').click
    elsif name == 'twitter'
      find(:css, 'i.fa.fa-twitter.fa-stack-1x.fa-inverse').click
    elsif name == 'slack'
      find(:css, 'i.fa.fa-slack.fa-stack-1x.fa-inverse').click
    else
      page.find('footer', text: 'Tutorials').click_link(name)
    end
  end



  def title_check(name)
    find(:id, name)
  end

end
