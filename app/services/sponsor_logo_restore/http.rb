class SponsorLogoRestore
  # Thin Net::HTTP plumbing: redirects, HEAD probes, URL encoding.
  module Http
    def get!(url)
      response = follow_redirects(URI(url))
      return response.body if response.code.to_i.between?(200, 299)

      raise "HTTP #{response.code} fetching #{url}"
    end

    def fetch(url)
      response = follow_redirects(URI(url))
      response.code.to_i.between?(200, 299) ? response.body : nil
    end

    def head_status(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.request(Net::HTTP::Head.new(uri.request_uri)).code
    end

    def encode(value)
      ERB::Util.url_encode(value)
    end

    def decode(value)
      URI.decode_www_form_component(value)
    end

    private

    def follow_redirects(uri, limit = 5)
      response = Net::HTTP.get_response(uri)
      return follow_redirects(URI(response['location']), limit - 1) if redirect?(response, limit)

      response
    end

    def redirect?(response, limit)
      response.is_a?(Net::HTTPRedirection) && limit.positive?
    end
  end
end
