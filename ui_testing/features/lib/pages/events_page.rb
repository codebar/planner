require 'capybara/dsl'

class EventsPage
  include Capybara::DSL

  BUTTON = '.button'
  LONDON_STUDENTS = '#london-students'

  def visit_events_page
    visit("/events")
  end

  def events_page_content
    page.find(:css, '.events-index')
  end

  def list_events
    page.find(:css, '.event')
    page.find(:id, 'minified')
  end

  def find_workshop
    page.find('section', text: 'Workshop')
  end

  def click_workshop
    find_workshop.click_link('Workshop')
  end

  def find_event
    page.find('section', text: 'Event')
  end

  def click_event
    find_event.click_link('Event')
  end

  def visit_event
    find('p', 'Attend our workshops to learn programming in a safe and supportive environment at your own pace, or to share your knowledge and coach our students.')
  end

  def sign_up_coach
    find('a', 'Sign up as a coach')
  end

  def sign_up_student
    find('a', 'I understand and meet the eligibility criteria. Sign me up as a student')
  end

  def event_details
    page.find(:css, '.large-12.columns')
    page.find(:css, '.medium-8.columns')
    page.find('h3', 'Venue')
  end

  def click_login
    find_link('Log in').click
  end

  def find_coach
    find_link('Attend as a coach')
  end

  def click_coach
    find_coach.click
  end

  def find_student
    find_link('Attend as a student')
  end

  def click_student
    find_student.click
  end

  def find_attend
    find_link('Attend')
  end

  def click_attend
    find_attend.click
  end

  def click_sign_up
    find_link('Sign up').click
  end

  def sign_up_page
    page.find('h2', 'Sign up')
  end

  def click_button(click)
    click_link(click)
  end

  def fail_student_coach
    page.find('a', 'Please tell us whether you want to attend as a student or coach.')
  end

  def click_fail
    fail_student_coach.click
  end

  def select_option
    page.find(:id, 'session_invitation_note_chosen')
  end

  def thanks_message
    page.find('div', 'Thanks for getting back to us ')
  end

end
