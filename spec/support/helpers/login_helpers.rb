module LoginHelpers
  def login(member)
    ApplicationController.any_instance.stub(:current_member).and_return(member)
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, :type => :feature
end
