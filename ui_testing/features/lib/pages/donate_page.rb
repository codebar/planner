require 'capybara/dsl'

class DonatePage
  include Capybara::DSL

  FORM_NAME_ID = 'donation_name'
  FORM_AMOUNT_ID = 'donation_amount'
  DONATE_BTN_ID = 'donate'
  IFRAME_NAME = 'stripe_checkout_app'
  MODAL_ARIA = 'section[aria-label="Secure Credit Card Form"]'

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
    page.driver.browser.switch_to.frame IFRAME_NAME
  end

  def find_modal
    find(MODAL_ARIA)
  end
end
