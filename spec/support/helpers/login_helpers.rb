module LoginHelpers
  def login(member)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(member)
    allow_any_instance_of(ApplicationController).to receive(:user_registration_not_complete).and_return(false)
  end

  def login_as_admin(member)
    member.add_role(:admin)
    login(member)
  end

  def login_as_organiser(member, chapter)
    member.add_role(:organiser, chapter)
    login(member)
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, :type => [:feature, :controller]
end
