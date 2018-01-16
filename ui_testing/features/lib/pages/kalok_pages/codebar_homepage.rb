require 'capybara/dsl'

class HomePage
  include Capybara::DSL

  def visit_home_page
    visit('/')
  end

  def find_codebar_logo
    find(:xpath, ".//a[@href='/']")
  end

  def click_codebar_logo
    find_codebar_logo.click
  end

  def find_blog_link
    find(:xpath, ".//a[@href='https://medium.com/@codebar']")
  end

  def click_blog_link
    find_blog_link.click
  end

  def find_event_link
    find('span', text: 'Events')
  end

  def click_event_link
    find_event_link.click
  end

  def find_tutorials_link
    find('span', text: 'Tutorials')
  end

  def click_tutorials_link
    find_tutorials_link.click
  end

  def find_coaches_link
    find('span', text: 'Coaches')
  end

  def click_coaches_link
    find_coaches_link.click
  end

  def find_sponsors_link
    find('span', text: 'Sponsors')
  end

  def click_sponsors_link
    find_sponsors_link.click
  end

  def find_jobs_link
    find('span', text: 'Jobs')
  end

  def click_jobs_link
    find_jobs_link.click
  end
end
