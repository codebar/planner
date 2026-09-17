class SponsorLogoRestore
  # Thin Net::HTTP plumbing: redirects, HEAD probes, URL encoding.
  module Http
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 30

    def get!(url, read_timeout: READ_TIMEOUT)
      response = get_response(URI(url), read_timeout:)
      return response.body if response.code.to_i.between?(200, 299)

      raise "HTTP #{response.code} fetching #{url}"
    end

    def get_response(url, read_timeout: READ_TIMEOUT)
      follow_redirects(URI(url), read_timeout:)
    end

    def head_status(url)
      uri = URI(url)
      http_for(uri).request(Net::HTTP::Head.new(uri.request_uri)).code
    end

    def html?(body)
      body.to_s.lstrip[0, 9].downcase.start_with?('<!doctype', '<html', '<?xml')
    end

    def encode(value)
      ERB::Util.url_encode(value)
    end

    def decode(value)
      URI.decode_www_form_component(value)
    end

    private

    def follow_redirects(uri, read_timeout: READ_TIMEOUT, limit: 5)
      response = http_for(uri, read_timeout:).get(uri.request_uri.empty? ? '/' : uri.request_uri)
      if redirect?(response, limit)
        return follow_redirects(URI.join(uri, response['location']), read_timeout:, limit: limit - 1)
      end

      response
    end

    def http_for(uri, read_timeout: READ_TIMEOUT)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = read_timeout
      http
    end

    def redirect?(response, limit)
      response.is_a?(Net::HTTPRedirection) && limit.positive?
    end
  end
end
