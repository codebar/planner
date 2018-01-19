require 'capybara'

class NavbarPartial
  include Capybara::DSL

  NAVBAR_CSS = 'nav.top-bar' unless const_defined?(:NAVBAR_CSS)
  ASIDE_CSS = 'aside.left-off-canvas-menu' unless const_defined?(:ASIDE_CSS)
  TEXT_IN_NAVBAR = 'Blog' unless const_defined?(:TEXT_IN_NAVBAR)


  def click_navbar_link(name)
    page.find(NAVBAR_CSS, text: name).click_link(name)
  end

  def click_aside_link(name)
    page.find(ASIDE_CSS, text: name).click_link(name)
  end

  def click_homepage_image
    page.find(NAVBAR_CSS, text: TEXT_IN_NAVBAR).find('img').click
  end

end
