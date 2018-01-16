require 'capybara/dsl'

class CodeBarFooter
  include Capybara::DSL

  CODE_OF_CONDUCT = 'Code of conduct'
  COACH_GUIDE = 'Coach guide'
  STUDENT_GUIDE = 'Student guide'
  BECOMING_SPONSOR_URL = 'Becoming a sponsor'
  FAQ = 'FAQ'

  def visit_home_page
    visit("/")
  end

  def visit_code_of_conduct
    find_link(CODE_OF_CONDUCT)
  end

  def visit_coach_guide
    find_link(COACH_GUIDE)
  end

  def visit_student_guide
    find_link(STUDENT_GUIDE)
  end

  def visit_tutorials
    page.find('footer', text: 'Tutorials').click_link('Tutorials')
  end

  def visit_becoming_sponsor
    find_link(BECOMING_SPONSOR_URL)
  end

  def visit_faq
    find_link('FAQ')
  end

  def visit_blog
    page.find('footer', text: 'Blog').click_link('Blog')
  end

  def visit_coaches
    page.find('footer', text: 'Coaches').click_link('Coaches')
  end

  def visit_sponsors
    page.find('footer', text: 'Sponsors').click_link('Sponsors')
  end

  def visit_events
    page.find('footer', text: 'Events').click_link('Events')
  end

  def visit_jobs
    page.find('footer', text: 'Jobs').click_link('Jobs')
  end

  def visit_donate
    page.find('footer', text: 'Donate').click_link('Donate')
  end
end
