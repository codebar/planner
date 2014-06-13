module LoginHelpers
  def login(member)
    ApplicationController.any_instance.stub(:current_user).and_return(member)
  end

  def login_as_admin(member)
    member.add_role(:admin)
    login(member)
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, :type => :feature
end
