require 'omniauth/strategies/codebar'

Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV['GITHUB_KEY'].blank? || ENV['GITHUB_SECRET'].blank?
    warn '*' * 80
    warn 'WARNING: Missing consumer key or secret. First, register an app with Github'
    warn 'Check README.md for instructions on how to set up Github Authentication.'
    warn '*' * 80
    if Rails.env.test?
      provider :github, 'fakekey', 'fakesecret', scope: 'user:email'
    end
  else
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email'
  end

  provider :codebar,
    auth_url: ENV.fetch('CODEBAR_AUTH_URL', 'http://localhost:3001'),
    audience: ENV.fetch('CODEBAR_AUDIENCE', 'planner')
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
