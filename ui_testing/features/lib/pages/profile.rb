require 'capybara/dsl'

class Profile
  include Capybara::DSL

  def find_title_profile
    find('h2', text: 'My Profile')
  end
end
