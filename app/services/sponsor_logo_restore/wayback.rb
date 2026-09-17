class SponsorLogoRestore
  # Reads the Wayback Machine CDX index and downloads archived copies of the
  # sponsor logos that used to live on assets.codebar.io.
  module Wayback
    ARCHIVE_PATH_PATTERN = %r{/uploads/sponsor/avatar/(\d+)/(.+)$}
    DOWNLOAD_RETRIES = 3
    RETRY_DELAY = 2

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

    def build_index(body)
      raise 'CDX returned a non-CDX (HTML) response' if html?(body)

      index = {}
      body.each_line do |line|
        parse_cdx_line(line)&.then { |entry| store_entry(index, entry) }
      end
      index
    end

    def store_entry(index, entry)
      key = [entry[:sponsor_id], entry[:filename].downcase]
      return unless better_capture?(entry, index[key])

      index[key] = entry
    end

    # Ranks complete image captures (200 + image/*) above error stubs; latest
    # wins within a rank. The old host's final crawl stored 522 error pages
    # for some logos, so the newest capture is not always the best one.
    def better_capture?(entry, current)
      return true unless current

      rank = capture_rank(entry)
      current_rank = capture_rank(current)
      rank > current_rank || (rank == current_rank && entry[:timestamp] > current[:timestamp])
    end

    def good_capture?(entry)
      entry && capture_rank(entry) == 1
    end

    def capture_rank(entry)
      entry[:status] == '200' && entry[:mimetype]&.start_with?('image/') ? 1 : 0
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

      { sponsor_id: match[1].to_i, filename: decode(match[2]), timestamp: columns[1],
        original_url: columns[2], mimetype: columns[3], status: columns[4] }
    end

    def archive_url(entry)
      "https://web.archive.org/web/#{entry[:timestamp]}im_/#{entry[:original_url]}"
    end

    def image?(body)
      return false unless body&.bytesize&.positive?

      byte = body.getbyte(0)
      return true if [0xFF, 0x89, 0x47].include?(byte) # JPEG, PNG, GIF magic bytes
      return svg?(body) if byte == 0x3C # '<': SVG markup or an HTML error page

      ico?(body)
    end

    def ico?(body)
      body.byteslice(0, 4).bytes == [0x00, 0x00, 0x01, 0x00]
    end

    def svg?(body)
      /\A\s*<(\?xml|svg)/i.match?(body.byteslice(0, 64))
    end
  end
end
