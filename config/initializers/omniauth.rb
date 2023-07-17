Rails.application.config.middleware.use OmniAuth::Builder do
  if ENV['GITHUB_KEY'].blank? || ENV['GITHUB_SECRET'].blank?
    if Rails.env.test?
      provider :github, 'fakekey', 'fakesecret', scope: 'user:email'
    else
      warn '*' * 80
      warn 'WARNING: Missing consumer key or secret. First, register an app with Github'
      warn 'Check README.md for instructions on how to set up Github Authentication.'
      warn '*' * 80
    end
  else
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email'
  end
end

OmniAuth.config.allowed_request_methods = [:post, :get]
