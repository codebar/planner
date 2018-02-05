require 'capybara/dsl'

class NavBar
  include Capybara::DSL

  HOMEPAGE_URL = '/'
  LOGO_XPATH = ".//a[@href='/']"
  BLOG_XPATH = ".//a[@href='https://medium.com/@codebar']"
  EVENTS_TEXT = 'Events'
  TUTORIALS_TEXT = 'Tutorials'
  COACHES_TEXT = 'Coaches'
  SPONSORS_TEXT = 'Sponsors'
  JOBS_TEXT = 'Jobs'
  DONATE_TEXT = 'Donate'

  def visit_home_page
    visit(HOMEPAGE_URL)
  end

  def find_codebar_logo
    find(:xpath, LOGO_XPATH)
  end

  def click_codebar_logo
    find_codebar_logo.click
  end

  def find_blog_link
    find(:xpath, BLOG_XPATH)
  end

  def click_blog_link
    find_blog_link.click
  end

  def find_event_link
    find('span', text: EVENTS_TEXT)
  end

  def click_event_link
    find_event_link.click
  end

  def find_tutorials_link
    find('span', text: TUTORIALS_TEXT)
  end

  def click_tutorials_link
    find_tutorials_link.click
  end

  def find_coaches_link
    find('span', text: COACHES_TEXT)
  end

  def click_coaches_link
    find_coaches_link.click
  end

  def find_sponsors_link
    find('span', text: SPONSORS_TEXT)
  end

  def click_sponsors_link
    find_sponsors_link.click
  end

  def find_jobs_link
    find('span', text: JOBS_TEXT)
  end

  def click_jobs_link
    find_jobs_link.click
  end

  def find_donate_link
    find('span', text: DONATE_TEXT)
  end

  def click_donate_link
    find_donate_link.click
  end
end
