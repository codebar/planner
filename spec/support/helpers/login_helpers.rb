module LoginHelpers
  def login(member)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(member)
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
end
