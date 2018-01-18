require 'capybara'
class EventsSomeSlugPage
  include Capybara::DSL

  EVENTS_SOME_SLUG_PAGE = 'http://localhost:3000/events/some-slug' unless const_defined?(:EVENTS_SOME_SLUG_PAGE)
  ATTEND_STUDENT_LINK = 'Attend as a student' unless const_defined?(:ATTEND_STUDENT_LINK)
  ATTEND_COACH_LINK = 'Attend as a coach' unless const_defined?(:ATTEND_COACH_LINK)
  RSVP_AS_STUDENT = 'RSVP as a student' unless const_defined?(:RSVP_AS_STUDENT)
  RSVP_AS_COACH = 'RSVP as a coach' unless const_defined?(:RSVP_AS_COACH)
  ALERT_BOX_ATTENDING = 'Your spot has been confirmed for Event! We look forward to seeing you there.'
  ALERT_BOX_NOT_ATTENDING = "We are so sad you can't make it, but thanks for letting us know"
  CANCEL_MY_SPOT = 'Cancel my spot'

  def visit_events_slug_page
    visit(EVENTS_SOME_SLUG_PAGE)
  end

  def click_attend_student
    click_link(ATTEND_STUDENT_LINK)
  end

  def click_attend_coach
    click_link(ATTEND_COACH_LINK)
  end

  def click_rsvp_student
    click_link(RSVP_AS_STUDENT)
  end

  def click_rsvp_coach
    click_link(RSVP_AS_COACH)
  end

  def click_cancel_spot
    click_link(CANCEL_MY_SPOT)
  end

  def find_alert_box_attending
    page.find('div', text: ALERT_BOX_ATTENDING)
  end

  def find_alert_box_not_attending
    page.find('div', text: ALERT_BOX_NOT_ATTENDING)
  end

end
