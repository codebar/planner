require 'capybara'

class CodeBarFooter
  include Capybara::DSL

  CODE_OF_CONDUCT_URL = '/code-of-conduct'
  COACH_GUIDE_URL = '/effective-teacher-guide'
  STUDENT_GUIDE_URL = '/student-guide'
  TUTORIALS_URL = 'http://tutorials.codebar.io'
  BECOMING_SPONSOR_URL = 'http://manual.codebar.io/becoming-a-sponsor'
  FAQ_URL = '/faq'
  BLOG_URL = 'https://medium.com/the-codelog'
  COACHES_URL = '/coaches'
  SPONSORS_URL = '/sponsors'
  EVENTS_URL = '/events'
  JOBS_URL = '/jobs'
  DONATE_URL = '/donations/new'
  SLACK_URL = 'https'
  GITHUB_URL =
  TWITTER_URL =
  FACEBOOK_URL =

  def visit_home_page
    visit("/")
  end

  def visit_code_of_conduct

  end

end
