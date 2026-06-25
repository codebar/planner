require 'omniauth'
require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'digest'

module OmniAuth
  module Strategies
    class Codebar
      include OmniAuth::Strategy

      option :name, 'codebar'
      option :auth_url, ENV.fetch('CODEBAR_AUTH_URL', 'http://localhost:3001')
      # The OAuth provider sets aud to the client_id ("planner") in the id_token.
      option :audience, ENV.fetch('CODEBAR_AUDIENCE', 'planner')
      option :client_options, {}

      # Request phase: redirect to auth app OAuth 2.1 authorize endpoint with PKCE
      def request_phase
        state = SecureRandom.hex(16)
        session['omniauth.codebar.state'] = state

        # Generate PKCE verifier and challenge
        code_verifier = generate_code_verifier
        session['omniauth.codebar.code_verifier'] = code_verifier
        code_challenge = generate_code_challenge(code_verifier)

        redirect_uri = callback_url
        session['omniauth.codebar.redirect_uri'] = redirect_uri
        params = {
          client_id: 'planner',
          redirect_uri: redirect_uri,
          response_type: 'code',
          state: state,
          scope: 'openid profile email',
          code_challenge: code_challenge,
          code_challenge_method: 'S256'
        }

        redirect "#{options.auth_url}/api/auth/oauth2/authorize?#{URI.encode_www_form(params)}"
      end

      # Callback phase: exchange code for tokens and build auth hash
      def callback_phase
        error = request.params['error']
        if error
          fail!(:auth_error, StandardError.new(error))
          return
        end

        # Verify state/nonce
        stored_state = session.delete('omniauth.codebar.state')
        received_state = request.params['state']

        if stored_state.nil? || received_state.nil? || stored_state != received_state
          return fail!(:csrf_detected, StandardError.new('State mismatch'))
        end

        code = request.params['code']
        if code.nil? || code.empty?
          return fail!(:missing_code, StandardError.new('Missing authorization code'))
        end

        code_verifier = session.delete('omniauth.codebar.code_verifier')
        if code_verifier.nil? || code_verifier.empty?
          return fail!(:missing_pkce, StandardError.new('Missing PKCE verifier'))
        end

        # Exchange code for tokens (server-to-server)
        tokens = exchange_code(code, code_verifier)
        if tokens.nil?
          return fail!(:exchange_failed, StandardError.new('Failed to exchange code'))
        end

        id_token = tokens['id_token']
        if id_token.nil? || id_token.empty?
          return fail!(:missing_id_token, StandardError.new('Missing id_token in token response'))
        end

        # Verify JWT
        payload = verify_jwt(id_token)
        if payload.nil?
          return fail!(:invalid_jwt, StandardError.new('JWT verification failed'))
        end

        # Build omniauth.auth hash
        email = payload['email'] || payload['sub']
        @env['omniauth.auth'] = AuthHash.new({
          provider: name,
          uid: email,
          info: {
            email: email,
            name: payload['name'] || email
          },
          credentials: {
            token: tokens['access_token'],
            expires: tokens['expires_at'],
            refresh_token: tokens['refresh_token']
          },
          extra: {
            raw_info: payload
          }
        })

        call_app!
      rescue StandardError => e
        return if env['omniauth.error']
        return fail!(:unknown_error, e)
      end

      private

      # The auth app sits behind Cloudflare, which rejects requests with
      # User-Agent "Ruby" (default from Net::HTTP). A descriptive
      # User-Agent on every outgoing request avoids this.
      def http_for(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 5
        http.read_timeout = 5
        http.use_ssl = (uri.scheme == 'https')
        http
      end

      # Generate PKCE code verifier (43-128 random characters)
      def generate_code_verifier
        SecureRandom.urlsafe_base64(32)
      end

      # Generate PKCE code challenge from verifier
      def generate_code_challenge(verifier)
        Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
      end

      # Exchange authorization code for tokens via OAuth 2.1 token endpoint
      def exchange_code(code, code_verifier)
        uri = URI("#{options.auth_url}/api/auth/oauth2/token")
        request = Net::HTTP::Post.new(uri.path)
        request['Content-Type'] = 'application/x-www-form-urlencoded'
        request['User-Agent'] = 'Codebar Planner/1.0'
        request.body = URI.encode_www_form({
          grant_type: 'authorization_code',
          code: code,
          client_id: 'planner',
          redirect_uri: session.delete('omniauth.codebar.redirect_uri') || callback_url,
          code_verifier: code_verifier
        })

        response = http_for(uri).request(request)

        if response.code.to_i == 200
          JSON.parse(response.body)
        else
          Rails.logger.warn "Codebar auth: token exchange failed: HTTP #{response.code} — #{response.body}"
          nil
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, JSON::ParserError => e
        Rails.logger.warn "Codebar auth: exchange failed: #{e.class}: #{e.message}"
        nil
      end

      # Verify JWT signature using auth app's JWKS.
      def verify_jwt(token)
        jwks = fetch_jwks
        return nil unless jwks

        decode = ->(jwks) {
          JWT.decode(token, nil, true, {
            algorithms: %w[RS256],
            jwks: jwks,
            iss: options.auth_url,
            aud: options.audience,
            verify_iss: true,
            verify_aud: true
          }).first
        }

        decode.call(jwks)
      rescue JWT::DecodeError => e
        if e.message.match?(/public key for kid|kid/)
          Rails.logger.info "Codebar auth: JWKS cache bust for kid=#{e.message[/kid:?\s*\S+/] || 'unknown'}"
          jwks = fetch_jwks(bust_cache: true)
          jwks ? decode.call(jwks) : nil
        else
          Rails.logger.warn "Codebar auth: JWT decode error: #{e.message}"
          nil
        end
      rescue JWT::ExpiredSignature
        Rails.logger.warn "Codebar auth: JWT expired"
        nil
      end

      # Fetch JWKS from auth app, cached for 15 minutes.
      # Pass bust_cache: true to skip cache and force refresh.
      def fetch_jwks(bust_cache: false)
        jwks_uri = URI("#{options.auth_url}/api/auth/jwks")
        cache_key = "codebar_auth_jwks_#{options.auth_url}"

        unless bust_cache
          cached = Rails.cache.read(cache_key)
          return cached if cached
        end

        jwks_request = Net::HTTP::Get.new(jwks_uri.path)
        jwks_request['User-Agent'] = 'Codebar Planner/1.0'
        response = http_for(jwks_uri).request(jwks_request)

        if response.code.to_i == 200
          jwks = JSON.parse(response.body)
          Rails.cache.write(cache_key, jwks, expires_in: 15.minutes)
          jwks
        else
          Rails.logger.warn "Codebar auth: JWKS fetch returned HTTP #{response.code}"
          nil
        end
      rescue StandardError => e
        Rails.logger.warn "Codebar auth: JWKS fetch failed: #{e.class}: #{e.message}"
        nil
      end

    end
  end
end
