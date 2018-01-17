require 'capybara/dsl'

class TutorialsPage
  include Capybara::DSL

  def visit_tutorials_page
    visit("http://tutorials.codebar.io/")
  end

  def visit_slack_community
    page.find('body', text: 'Join the codebar community on Slack').click_link('Join the codebar community on Slack')
  end

  def tutorials_link(link_page)
    click_link(link_page)
  end

end
