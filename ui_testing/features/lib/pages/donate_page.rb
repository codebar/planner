require 'capybara/dsl'

class DonatePage
  include Capybara::DSL

  FORM_NAME_ID = 'donation_name'
  FORM_AMOUNT_ID = 'donation_amount'
  DONATE_BTN_ID = 'donate'
  POP_UP_ARIA = 'section[aria-label="Secure Credit Card Form"]'

  def fill_name(name)
    fill_in(FORM_NAME_ID, :with => name)
  end

  def fill_amount(amount)
    fill_in(FORM_AMOUNT_ID, :with => amount)
  end

  def click_donate
    click_on(DONATE_BTN_ID)
  end

  def find_pop_up
    find(POP_UP_ARIA).visible?
  end
end
