require 'capybara/dsl'

class CodeBarFooter
  include Capybara::DSL

  def visit_slack
    find(:css, 'i.fa.fa-slack.fa-stack-1x.fa-inverse').click
  end

  def visit_github
    find(:css, 'i.fa.fa-github.fa-stack-1x.fa-inverse').click
  end

  def visit_twitter
    find(:css, 'i.fa.fa-twitter.fa-stack-1x.fa-inverse').click
  end

  def visit_facebook
    find(:css, 'i.fa.fa-facebook.fa-stack-1x.fa-inverse').click
  end
end
