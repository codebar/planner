require 'capybara/dsl'

class Invitation
  include Capybara::DSL

  def event_to_cancel
    page.find('a', '.button.round.expand').click
  end

  def cancel_attendance
    page.find('a', 'I can no longer attend').click
  end

  def cancelled_message
    page.find('div', "We are so sad you can't make it, but thanks for letting us know")
  end
end
