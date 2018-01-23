require 'capybara/dsl'

class UpdateProfile
  include Capybara::DSL

  ABOUT_ME_FIELD = '#member_about_you'

  def visit_update_profile
    visit('/member/edit')
  end

  def find_aboutme_field
    find(:id, ABOUT_ME_FIELD)
  end

  def fill_aboutme
    fill_in(find_aboutme_field, :with => "changed about me")
  end

end
