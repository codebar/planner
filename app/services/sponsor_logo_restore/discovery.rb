class SponsorLogoRestore
  # Discovers the sponsor logos referenced by the live sponsors page and
  # classifies each one as present, missing, or uncheckable.
  module Discovery
    def sponsor_logos(source_url)
      Nokogiri::HTML(get!(source_url)).css('img').filter_map do |img|
        parse_page_path(img['src'])
      end.uniq
    end

    # -> [missing logos, failed entries]; logos in neither list are present.
    def classify(logos)
      missing = []
      failed = []
      logos.each do |logo|
        outcome = classify_one(logo, logos.size)
        missing << logo if outcome == :missing
        failed << outcome if outcome.is_a?(Hash)
      end
      [missing, failed]
    end

    # -> [index, nil] on success, [nil, reason] when the index is unavailable.
    def load_index(missing)
      return [{}, nil] if missing.empty?

      report('Fetching Wayback CDX index; this can take a couple of minutes')
      [wayback_index, nil]
    rescue StandardError => e
      [nil, "Wayback CDX index unavailable: #{e.message}"]
    end

    private

    def parse_page_path(src)
      match = src&.match(PAGE_PATH_PATTERN)
      return unless match

      { sponsor_id: match[1].to_i, filename: decode(match[2]) }
    end

    # -> :missing, :present, or a failure hash when the check errored
    def classify_one(logo, total)
      @checked = @checked.to_i + 1
      report("Availability check: #{@checked}/#{total}") if (@checked % 50).zero? || @checked == total

      logo_present?(logo) ? :present : :missing
    rescue StandardError => e
      failure(logo, "availability check failed: #{e.message}")
    end

    # Checks the public URL rather than the S3 API so the result reflects
    # exactly what a visitor's browser can load.
    def logo_present?(logo)
      head_status(public_url(logo)) == '200'
    end

    def public_url(logo)
      host = "#{bucket}.s3.#{region}.amazonaws.com"
      path = "uploads/sponsor/#{logo[:sponsor_id]}/#{encode(logo[:filename])}"
      "https://#{host}/#{path}"
    end
  end
end
