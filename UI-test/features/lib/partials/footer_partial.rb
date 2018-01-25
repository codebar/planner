require 'capybara'

class FooterPartial
  include Capybara::DSL

  FACEBOOK_LINK_CSS = 'i.fa.fa-facebook.fa-stack-1x.fa-inverse' unless const_defined?(:FACEBOOK_LINK_CSS)
  GITHUB_LINK_CSS = 'i.fa.fa-github.fa-stack-1x.fa-inverse' unless const_defined?(:GITHUB_LINK_CSS)
  TWITTER_LINK_CSS = 'i.fa.fa-twitter.fa-stack-1x.fa-inverse' unless const_defined?(:TWITTER_LINK_CSS)
  SLACK_LINK_CSS = 'i.fa.fa-slack.fa-stack-1x.fa-inverse' unless const_defined?(:SLACK_LINK_CSS)


  def click_footer_link(name)
    if name == 'Facebook'
      find(:css, FACEBOOK_LINK_CSS).click
    elsif name == 'Github'
      find(:css, GITHUB_LINK_CSS).click
    elsif name == 'Twitter'
      find(:css, TWITTER_LINK_CSS).click
    elsif name == 'Slack'
      find(:css, SLACK_LINK_CSS).click
    else
      page.find('footer', text: name).click_link(name)
    end
  end

end
