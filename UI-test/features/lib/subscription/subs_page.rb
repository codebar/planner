require 'capybara'

class ManageSubs
  include Capybara::DSL

  SIDEBAR_MENU = 'Menu' unless const_defined?(:SIDEBAR_MENU)
  SUBS_LINK = 'Manage subscriptions' unless const_defined?(:SUBS_LINK)
  SUBS_BUTTON_ID = 'cambridge-students' unless const_defined?(:SUBS_BUTTON_ID)
  UPDATED_SUBS_NOTIFICATION = 'You have subscribed' unless const_defined?(:UPDATED_SUBS_NOTIFICATION)
  UPDATED_UNSUBS_NOTIFICATION = 'You have unsubscribed' unless const_defined?(:UPDATED_SUBS_NOTIFICATION)

  def open_sidebar_menu
    click_link(SIDEBAR_MENU)
  end

  def click_subs_link
    click_link(SUBS_LINK)
  end

  def manage_subs_page
    find('h2', text: 'Subscriptions', exact: true)
  end

  def select_sub
    find_button(SUBS_BUTTON_ID).click
  end

  def confirm_subs_updated
    find('div', text: UPDATED_SUBS_NOTIFICATION, exact: true).visible?
  end

end
