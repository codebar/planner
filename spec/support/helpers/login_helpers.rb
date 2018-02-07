module LoginHelpers
  def login(member)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(member)
  end

  def login_mock_omniauth(member, login_link = 'Sign in')
    OmniAuth.config.mock_auth[:github] = {
      provider: member.auth_services.first.provider,
      uid: member.auth_services.first.uid,
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    }
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
end

RSpec.configure do |config|
  config.include LoginHelpers, type: %i[feature controller]
end
