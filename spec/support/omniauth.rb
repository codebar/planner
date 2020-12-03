require 'omniauth'

module OmniauthMacros
  def mock_auth_hash(name: Faker::Name.name, email: Faker::Internet.email, provider: 'github', uid: uid)
    OmniAuth.config.mock_auth[:github] = {
      provider: provider,
      uid: uid,
      info: {
        name: name,
        email: email,
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      }
    }
  end
end

RSpec.configure do |config|
  config.include(OmniauthMacros)
end

OmniAuth.config.test_mode = true
