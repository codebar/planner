class SponsorLogoRestore
  # Reads the Wayback Machine CDX index and downloads archived copies of the
  # sponsor logos that used to live on assets.codebar.io.
  module Wayback
    CDX_QUERY_URL = 'https://web.archive.org/cdx/search/cdx'.freeze
    ARCHIVE_HOST_PREFIX = 'assets.codebar.io/b/uploads/sponsor/avatar'.freeze
    ARCHIVE_PATH_PATTERN = %r{/uploads/sponsor/avatar/(\d+)/(.+)$}
    DOWNLOAD_RETRIES = 3
    RETRY_DELAY = 2

    def wayback_index
      index = {}
      get!(cdx_url).each_line do |line|
        entry = parse_cdx_line(line)
        next unless entry

        key = [entry[:sponsor_id], entry[:filename].downcase]
        index[key] = entry if index[key].nil? || entry[:timestamp] > index[key][:timestamp]
      end
      index
    end

    def download_archive(entry)
      DOWNLOAD_RETRIES.times do |attempt|
        sleep(delay)
        body = fetch(archive_url(entry))
        return body if image?(body)

        sleep(RETRY_DELAY) unless attempt == DOWNLOAD_RETRIES - 1
      end
      nil
    end

    private

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
      body&.bytesize&.positive? && [0xFF, 0x89, 0x47, 0x3C].include?(body.getbyte(0))
    end

    def cdx_url
      "#{CDX_QUERY_URL}?url=#{ARCHIVE_HOST_PREFIX}*&output=text&collapse=urlkey&limit=100_000"
    end
  end
end
