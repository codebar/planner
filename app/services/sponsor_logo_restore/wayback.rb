class SponsorLogoRestore
  # Reads the Wayback Machine CDX index and downloads archived copies of the
  # sponsor logos that used to live on assets.codebar.io.
  module Wayback
    CDX_QUERY_URL = 'https://web.archive.org/cdx/search/cdx'.freeze
    ARCHIVE_HOST_PREFIX = 'assets.codebar.io/b/uploads/sponsor/avatar'.freeze
    ARCHIVE_PATH_PATTERN = %r{/uploads/sponsor/avatar/(\d+)/(.+)$}
    DOWNLOAD_RETRIES = 3
    CDX_ATTEMPTS = 2
    CDX_READ_TIMEOUT = 180
    RETRY_DELAY = 2

    def wayback_index
      attempt_cdx(CDX_ATTEMPTS)
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

    def attempt_cdx(remaining)
      build_index(get!(cdx_url, read_timeout: CDX_READ_TIMEOUT))
    rescue StandardError
      raise if remaining <= 1

      report('CDX fetch failed once; retrying')
      sleep(retry_delay)
      attempt_cdx(remaining - 1)
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
