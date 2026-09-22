require 'rails_helper'

RSpec.describe 'OmniAuth provider error callback' do
  # Regression: a provider error redirect (error=invalid_scope, pkce required,
  # ...) used to crash the middleware stack with NoMethodError '[]=' for nil
  # instead of redirecting to the failure page.
  around do |example|
    OmniAuth.config.test_mode = false
    example.run
    OmniAuth.config.test_mode = true
  end

  it 'redirects to the failure page instead of raising' do
    get '/auth/codebar/callback', params: {
      error: 'invalid_request',
      error_description: 'pkce is required for public clients',
      state: 'some-state',
      iss: 'https://auth.codebar.io'
    }

    expect(response).to have_http_status(:redirect)
    expect(response.location).to start_with('/auth/failure?')
  end

  it 'shows the authentication error flash after the failure redirect' do
    get '/auth/failure', params: { message: 'auth_error', strategy: 'codebar' }

    expect(response).to redirect_to(root_url)
  end
end
