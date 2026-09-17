class SponsorLogoRestore
  # Fetches the Wayback Machine CDX index (with retry, caching, and throttling
  # handling) for the old assets.codebar.io asset host.
  module CdxFetch
    CDX_QUERY_URL = 'https://web.archive.org/cdx/search/cdx'.freeze
    ARCHIVE_HOST_PREFIX = 'assets.codebar.io/b/uploads/sponsor/avatar'.freeze
    CDX_ATTEMPTS = 3
    CDX_READ_TIMEOUT = 180
    CDX_RETRY_DELAY = 15

    # Raised for non-2xx CDX responses; carries Retry-After when present.
    class CDXFetchError < StandardError
      attr_reader :retry_after

      def initialize(response)
        super("HTTP #{response.code} fetching CDX index")
        @retry_after = response['retry-after']&.to_i
      end
    end

    # The CDX index is immutable historical data; cache it to skip the slow query.
    def cdx_body
      cached = cache_read('cdx-index')
      return reuse_cached_cdx(cached) if cached

      report('Fetching Wayback CDX index; this can take a couple of minutes')
      body = fetch_cdx_with_retry
      cache_write('cdx-index', body)
      body
    end

    def cdx_url
      "#{CDX_QUERY_URL}?url=#{ARCHIVE_HOST_PREFIX}*&output=text&collapse=urlkey&limit=100000"
    end

    private

    def reuse_cached_cdx(cached)
      report('Using cached CDX index (set REFRESH_CACHE=1 to refresh)')
      cached
    end

    def fetch_cdx_with_retry(remaining = CDX_ATTEMPTS)
      fetch_cdx_response
    rescue StandardError => e
      raise if remaining <= 1

      report("CDX fetch failed (#{e.message}); retrying")
      sleep(cdx_retry_wait(e))
      fetch_cdx_with_retry(remaining - 1)
    end

    def fetch_cdx_response
      response = get_response(URI(cdx_url), read_timeout: CDX_READ_TIMEOUT)
      raise CDXFetchError, response unless response.code.to_i.between?(200, 299)

      response.body
    end

    def cdx_retry_wait(error)
      retry_after = error.respond_to?(:retry_after) ? error.retry_after : nil
      retry_after || cdx_retry_delay
    end
  end
end
