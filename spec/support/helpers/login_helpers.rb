module LoginHelpers
  module LoginStub
    cattr_accessor :current_user

    def current_user
      return LoginStub.current_user if LoginStub.current_user

      super
    end
  end

  def login(member)
    if respond_to?(:visit)
      visit '/logout'
      mock_auth_hash(provider: member.auth_services.first.provider,
                     uid: member.auth_services.first.uid)
      visit '/auth/github'
    else
      ApplicationController.prepend(LoginStub) unless ApplicationController < LoginStub
      LoginStub.current_user = member
    end
  end

  def login_mock_omniauth(member, login_link = 'Sign in')
    mock_auth_hash(provider: member.auth_services.first.provider,
                   uid: member.auth_services.first.uid)
    click_on login_link
  end

  def login_as_admin(member)
    member.add_role(:admin)
    login(member)
  end

  def login_as_organiser(member, chapter)
    member.add_role(:organiser, chapter)
    login(member)
  end

  def mock_github_auth
    mock_auth_hash
  end

  def accept_toc
    check :terms
    click_on 'Accept'
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, type: %i[feature controller]

  config.after do
    LoginHelpers::LoginStub.current_user = nil
  end
end
