require 'capybara/dsl'

class UpdateProfile
  include Capybara::DSL

  ABOUT_ME_FIELD = 'member_about_you'

  def visit_update_profile
    visit('/member/edit')
  end

  def fill_aboutme
    fill_in(ABOUT_ME_FIELD, :with => "changed about me")
  end

  def click_save
    find(:css, '.button.round.right').click
  end

  def confirmation_message
    find(:css, '.alert-box.info').text
  end
end
