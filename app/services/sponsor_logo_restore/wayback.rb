class SponsorLogoRestore
  # Reads the Wayback Machine CDX index and downloads archived copies of the
  # sponsor logos that used to live on assets.codebar.io.
  module Wayback
    CDX_QUERY_URL = 'https://web.archive.org/cdx/search/cdx'.freeze
    ARCHIVE_HOST_PREFIX = 'assets.codebar.io/b/uploads/sponsor/avatar'.freeze
    ARCHIVE_PATH_PATTERN = %r{/uploads/sponsor/avatar/(\d+)/(.+)$}
    DOWNLOAD_RETRIES = 3
    CDX_ATTEMPTS = 3
    CDX_READ_TIMEOUT = 180
    CDX_RETRY_DELAY = 15
    RETRY_DELAY = 2

    # Raised for non-2xx CDX responses; carries Retry-After when present.
    class CDXFetchError < StandardError
      attr_reader :retry_after

      def initialize(response)
        super("HTTP #{response.code} fetching CDX index")
        @retry_after = response['retry-after']&.to_i
      end
    end

    def wayback_index
      build_index(cdx_body)
    end

    def download_archive(entry)
      DOWNLOAD_RETRIES.times do |attempt|
        sleep(delay)
        action, payload = attempt_download(entry)
        return payload if %i[restore miss].include?(action)

        sleep(payload) unless attempt == DOWNLOAD_RETRIES - 1
      end
      nil
    end

    private

    # The CDX index is immutable historical data; cache the raw response so
    # repeated practice runs skip the multi-minute query.
    def cdx_body
      cached = cache_read('cdx-index')
      return reuse_cached_cdx(cached) if cached

      report('Fetching Wayback CDX index; this can take a couple of minutes')
      body = fetch_cdx_with_retry
      cache_write('cdx-index', body)
      body
    end

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

    def build_index(body)
      raise 'CDX returned a non-CDX (HTML) response' if html?(body)

      index = {}
      body.each_line do |line|
        entry = parse_cdx_line(line)
        next unless entry

        key = [entry[:sponsor_id], entry[:filename].downcase]
        index[key] = entry if index[key].nil? || entry[:timestamp] > index[key][:timestamp]
      end
      index
    end

    # -> [:restore, image body], [:miss, nil] for a permanent 404, or
    # [:retry, seconds] for a transient failure (honours Retry-After on 429s)
    def attempt_download(entry)
      response = get_response(archive_url(entry))
      return [:restore, response.body] if image?(response.body)
      return [:miss, nil] if response.code == '404'

      wait = response.code == '429' ? response['retry-after']&.to_i : retry_delay
      [:retry, wait || retry_delay]
    end

    def parse_cdx_line(line)
      columns = line.split(' ')
      match = columns[2]&.match(ARCHIVE_PATH_PATTERN)
      return unless match

      { sponsor_id: match[1].to_i, filename: decode(match[2]),
        timestamp: columns[1], original_url: columns[2] }
    end

    def archive_url(entry)
      "https://web.archive.org/web/#{entry[:timestamp]}im_/#{entry[:original_url]}"
    end

    def image?(body)
      return false unless body&.bytesize&.positive?

      byte = body.getbyte(0)
      return true if [0xFF, 0x89, 0x47].include?(byte) # JPEG, PNG, GIF magic bytes
      return svg?(body) if byte == 0x3C # '<': SVG markup or an HTML error page

      false
    end

    def svg?(body)
      /\A\s*<(\?xml|svg)/i.match?(body.byteslice(0, 64))
    end

    def cdx_url
      "#{CDX_QUERY_URL}?url=#{ARCHIVE_HOST_PREFIX}*&output=text&collapse=urlkey&limit=100000"
    end
  end
end
