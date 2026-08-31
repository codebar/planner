require 'omniauth'

module OmniauthMacros
  def mock_auth_hash(name: Faker::Name.name, email: Faker::Internet.email, provider: 'codebar', uid: 'uid',
    github_id: nil)
    OmniAuth.config.mock_auth[provider.to_sym] = {
      provider:,
      uid:,
      info: {
        name:,
        email:
      },
      credentials: {
        token: 'mock_token',
        secret: 'mock_secret'
      },
      extra: {
        raw_info: {
          'github_id' => github_id
        }.compact
      }
    }
  end
end

RSpec.configure do |config|
  config.include(OmniauthMacros)
end

OmniAuth.config.test_mode = true
