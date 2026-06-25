require 'rails_helper'
require 'omniauth'
require 'webmock/rspec'
require 'jwt'

RSpec.describe OmniAuth::Strategies::Codebar do
  subject(:strategy) { described_class.new(app, auth_url: auth_url, audience: 'planner') }

  let(:app) { ->(_env) { [200, {}, ['OK']] } }
  let(:auth_url) { 'http://localhost:3001' }
  let(:token_url) { "#{auth_url}/api/auth/oauth2/token" }
  let(:jwks_url)  { "#{auth_url}/api/auth/jwks" }

  let(:email) { 'user@example.com' }
  let(:name) { 'Alice Smith' }

  let(:base_env) do
    {
      'rack.session' => {},
      'rack.input' => StringIO.new(''),
      'REQUEST_METHOD' => 'GET',
      'SERVER_NAME' => 'localhost',
      'SERVER_PORT' => '3000',
      'rack.url_scheme' => 'http',
    }
  end

  before do
    OmniAuth.config.test_mode = false
  end

  after do
    OmniAuth.config.test_mode = true
    WebMock.reset!
  end

  def build_env(path, query: '', session: {})
    base_env.merge(
      'PATH_INFO' => path,
      'QUERY_STRING' => query,
      'rack.session' => session,
    )
  end

  describe '#request_phase' do
    it 'stores state and PKCE verifier in session and redirects to authorize endpoint' do
      env = build_env('/auth/codebar')
      status, headers, _body = strategy.call(env)

      expect(status).to eq(302)
      expect(env['rack.session']['omniauth.codebar.state']).to be_present
      expect(env['rack.session']['omniauth.codebar.code_verifier']).to be_present

      location = headers['Location']
      expect(location).to include('/api/auth/oauth2/authorize')
      expect(location).to include('client_id=planner')
      expect(location).to include('response_type=code')
      expect(location).to include('code_challenge=')
      expect(location).to include('code_challenge_method=S256')
      expect(location).to include('scope=openid+profile+email')
      expect(env['rack.session']['omniauth.codebar.redirect_uri']).to eq('http://localhost:3000/auth/codebar/callback')
    end

    it 'generates unique state per request' do
      env1 = build_env('/auth/codebar')
      strategy.call(env1)
      state1 = env1['rack.session']['omniauth.codebar.state']

      env2 = build_env('/auth/codebar')
      strategy.call(env2)
      state2 = env2['rack.session']['omniauth.codebar.state']

      expect(state1).not_to eq(state2)
    end
  end

  describe 'callback error paths' do
    it 'fails with csrf_detected when state is missing from session' do
      env = build_env('/auth/codebar/callback', query: 'code=abc&state=some-state')
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:csrf_detected)
    end

    it 'fails with csrf_detected when state does not match' do
      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=wrong-state',
        session: { 'omniauth.codebar.state' => 'correct-state' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:csrf_detected)
    end

    it 'fails with missing_code when code is absent' do
      env = build_env('/auth/codebar/callback',
        query: 'state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:missing_code)
    end

    it 'fails with missing_code when code is empty' do
      env = build_env('/auth/codebar/callback',
        query: 'code=&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:missing_code)
    end

    it 'fails with missing_pkce when code_verifier is missing' do
      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:missing_pkce)
    end

    it 'fails with exchange_failed when token endpoint returns error' do
      stub_request(:post, token_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 400, body: '{"error":"invalid_grant"}')

      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state', 'omniauth.codebar.code_verifier' => 'verifier', 'omniauth.codebar.redirect_uri' => 'http://localhost:3000/auth/codebar/callback' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:exchange_failed)
    end

    it 'sends a custom User-Agent on token exchange requests' do
      stub = stub_request(:post, token_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 400, body: '{"error":"invalid_grant"}')

      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state', 'omniauth.codebar.code_verifier' => 'verifier', 'omniauth.codebar.redirect_uri' => 'http://localhost:3000/auth/codebar/callback' })
      strategy.call!(env)

      expect(stub).to have_been_requested
    end

    it 'fails with missing_id_token when token response lacks id_token' do
      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: 'foo' }.to_json, headers: { 'Content-Type' => 'application/json' })

      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state', 'omniauth.codebar.code_verifier' => 'verifier', 'omniauth.codebar.redirect_uri' => 'http://localhost:3000/auth/codebar/callback' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:missing_id_token)
    end

    it 'fails with invalid_jwt when JWT verification fails' do
      stub_request(:post, token_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 200, body: { access_token: 'foo', id_token: 'invalid.jwt.token' }.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, jwks_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 200, body: { keys: [{ kty: 'RSA', kid: 'test', n: 'abc', e: 'AQAB' }] }.to_json)

      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state', 'omniauth.codebar.code_verifier' => 'verifier', 'omniauth.codebar.redirect_uri' => 'http://localhost:3000/auth/codebar/callback' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_a(StandardError)
      expect(env['omniauth.error.type']).to eq(:invalid_jwt)
    end
  end

  describe 'successful callback' do
    let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:jwk) { JWT::JWK.new(rsa_key, { kid: 'test-key-1' }) }
    let(:id_token) do
      JWT.encode(
        { 'sub' => email, 'name' => name, 'iss' => auth_url, 'aud' => 'planner', 'iat' => Time.now.to_i, 'exp' => Time.now.to_i + 3600 },
        rsa_key,
        'RS256',
        { kid: 'test-key-1' }
      )
    end

    before do
      stub_request(:post, token_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 200, body: {
          access_token: 'test-access-token',
          id_token: id_token,
          token_type: 'Bearer',
          expires_in: 900
        }.to_json, headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, jwks_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 200, body: { keys: [jwk.export] }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'builds the auth hash with correct data' do
      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=some-state',
        session: { 'omniauth.codebar.state' => 'some-state', 'omniauth.codebar.code_verifier' => 'verifier', 'omniauth.codebar.redirect_uri' => 'http://localhost:3000/auth/codebar/callback' })
      strategy.call!(env)

      auth_hash = env['omniauth.auth']
      expect(auth_hash).to be_present
      expect(auth_hash[:provider]).to eq('codebar')
      expect(auth_hash[:uid]).to eq(email)
      expect(auth_hash[:info][:email]).to eq(email)
      expect(auth_hash[:info][:name]).to eq(name)
      expect(auth_hash[:credentials][:token]).to eq('test-access-token')
      expect(auth_hash[:extra][:raw_info]).to include('sub' => email, 'name' => name)
    end
  end

  describe 'call! routing' do
    it 'routes /auth/codebar to request phase' do
      env = build_env('/auth/codebar')
      strategy.call!(env)
      expect(env['rack.session']['omniauth.codebar.state']).to be_present
      expect(env['rack.session']['omniauth.codebar.code_verifier']).to be_present
    end

    it 'routes /auth/codebar/callback to callback phase' do
      stub_request(:post, token_url)
        .with(headers: { 'User-Agent' => 'Codebar Planner/1.0' })
        .to_return(status: 400, body: '{"error":"invalid_grant"}')

      env = build_env('/auth/codebar/callback',
        query: 'code=abc&state=test-state',
        session: { 'omniauth.codebar.state' => 'test-state', 'omniauth.codebar.code_verifier' => 'verifier', 'omniauth.codebar.redirect_uri' => 'http://localhost:3000/auth/codebar/callback' })
      strategy.call!(env)
      expect(env['omniauth.error']).to be_present
      expect(env['omniauth.error.type']).to eq(:exchange_failed)
    end
  end
end
