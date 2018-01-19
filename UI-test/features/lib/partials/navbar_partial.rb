require 'capybara'

class NavbarPartial
  include Capybara::DSL

  NAVBAR_CSS = 'nav.top-bar' unless const_defined?(:NAVBAR_CSS)
  ASIDE_CSS = 'aside.left-off-canvas-menu' unless const_defined?(:ASIDE_CSS)
  TEXT_IN_NAVBAR = 'Blog' unless const_defined?(:TEXT_IN_NAVBAR)
  BLOG_TEXT = 'Blog' unless const_defined?(:BLOG_TEXT)
  EVENTS_TEXT = 'Events' unless const_defined?(:EVENTS_TEXT)
  TUTORIALS_TEXT = 'Tutorials' unless const_defined?(:TUTORIALS_TEXT)
  COACHES_TEXT = 'Coaches' unless const_defined?(:COACHES_TEXT)
  SPONSORS_TEXT = 'Sponsors' unless const_defined?(:SPONSORS_TEXT)
  JOBS_TEXT = 'Jobs' unless const_defined?(:JOBS_TEXT)
  SIGN_IN_TEXT = 'Sign in' unless const_defined?(:SIGN_IN_TEXT)
  MENU_TEXT = 'Menu' unless const_defined?(:MENU_TEXT)
  TEXT_IN_ASIDE = 'Sign out' unless const_defined?(:TEXT_IN_ASIDE)
  JOBS_ASIDE_TEXT = 'Jobs' unless const_defined?(:JOBS_ASIDE_TEXT)
  LIST_A_JOB_ASIDE_TEXT = 'List a Job' unless const_defined?(:LIST_A_JOB_ASIDE_TEXT)
  MY_PROFILE_ASIDE_TEXT = 'My Profile' unless const_defined?(:MY_PROFILE_ASIDE_TEXT)
  MY_DASHBOARD_ASIDE_TEXT = 'My Dashboard' unless const_defined?(:MY_DASHBOARD_ASIDE_TEXT)
  INVITATIONS_ASIDE_TEXT = 'Invitations' unless const_defined?(:INVITATIONS_ASIDE_TEXT)
  MANAGE_SUBSCRIPTIONS_ASIDE_TEXT = 'Manage subscriptions' unless const_defined?(:MANAGE_SUBSCRIPTIONS_ASIDE_TEXT)
  UPDATE_YOUR_DETAILS_ASIDE_TEXT = 'Update your details' unless const_defined?(:UPDATE_YOUR_DETAILS_ASIDE_TEXT)
  SIGN_OUT_ASIDE_TEXT = 'Sign out' unless const_defined?(:SIGN_OUT_ASIDE_TEXT)



  # navbar links
  def click_navbar_link(name)
    page.find(NAVBAR_CSS, text: name).click_link(name)
  end

  def click_homepage_image
    page.find(NAVBAR_CSS, text: TEXT_IN_NAVBAR).find('img').click
  end

  def click_blog
    page.find(NAVBAR_CSS, text: BLOG_TEXT).click_link(BLOG_TEXT)
  end

  def click_events
    page.find(NAVBAR_CSS, text: EVENTS_TEXT).click_link(EVENTS_TEXT)
  end

  def click_tutorials
    page.find(NAVBAR_CSS, text: TUTORIALS_TEXT).click_link(TUTORIALS_TEXT)
  end

  def click_coaches
    page.find(NAVBAR_CSS, text: COACHES_TEXT).click_link(COACHES_TEXT)
  end

  def click_sponsors
    page.find(NAVBAR_CSS, text: SPONSORS_TEXT).click_link(SPONSORS_TEXT)
  end

  def click_jobs
    page.find(NAVBAR_CSS, text: JOBS_TEXT).click_link(JOBS_TEXT)
  end

  def click_sign_in
    page.find(NAVBAR_CSS, text: SIGN_IN_TEXT).click_link(SIGN_IN_TEXT)
  end

  def click_menu
    page.find(NAVBAR_CSS, text: MENU_TEXT).click_link(MENU_TEXT)
  end


# aside links
  def click_aside_link(name)
    page.find(ASIDE_CSS, text: name).click_link(name)
  end

  def aside_check
    page.find(ASIDE_CSS, text: TEXT_IN_ASIDE)
  end

  def click_aside_jobs
    page.find(ASIDE_CSS, text: JOBS_ASIDE_TEXT).click_link(JOBS_ASIDE_TEXT)
  end

  def click_aside_list_a_job
    page.find(ASIDE_CSS, text: LIST_A_JOB_ASIDE_TEXT).click_link(LIST_A_JOB_ASIDE_TEXT)
  end

  def click_aside_my_profile
    page.find(ASIDE_CSS, text: MY_PROFILE_ASIDE_TEXT).click_link(MY_PROFILE_ASIDE_TEXT)
  end

  def click_aside_my_dashboard
    page.find(ASIDE_CSS, text: MY_DASHBOARD_ASIDE_TEXT).click_link(MY_DASHBOARD_ASIDE_TEXT)
  end

  def click_aside_invitations
    page.find(ASIDE_CSS, text: INVITATIONS_ASIDE_TEXT).click_link(INVITATIONS_ASIDE_TEXT)
  end

  def click_aside_manage_subscriptions
    page.find(ASIDE_CSS, text: MANAGE_SUBSCRIPTIONS_ASIDE_TEXT).click_link(MANAGE_SUBSCRIPTIONS_ASIDE_TEXT)
  end

  def click_aside_update_your_details
    page.find(ASIDE_CSS, text: UPDATE_YOUR_DETAILS_ASIDE_TEXT).click_link(UPDATE_YOUR_DETAILS_ASIDE_TEXT)
  end

  def click_aside_sign_out
    page.find(ASIDE_CSS, text: SIGN_OUT_ASIDE_TEXT).click_link(SIGN_OUT_ASIDE_TEXT)
  end

end
