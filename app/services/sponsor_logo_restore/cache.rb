require 'digest'
require 'json'

class SponsorLogoRestore
  # Disk cache for slow, stable inputs (availability probes, the CDX index) so
  # repeated practice runs do not refetch them. Enabled outside the test
  # environment; SPONSOR_LOGO_CACHE=1 opts in during tests. REFRESH_CACHE=1
  # forces a refetch; CACHE_TTL_MINUTES bounds staleness (default 6 hours).
  module Cache
    DEFAULT_TTL_MINUTES = 360

    def cache_read(key)
      return nil unless cache_enabled? && !cache_refresh?

      entry = read_entry(key)
      return nil if entry.nil? || cache_expired?(entry)

      entry['value']
    end

    def cache_write(key, value)
      return unless cache_enabled?

      file = entry_path(key)
      file.dirname.mkpath
      file.write(JSON.generate(value:, fetched_at: Time.now.to_i))
    rescue StandardError => e
      report("Cache write failed (continuing without cache): #{e.message}")
    end

    private

    def cache_enabled?
      ENV['SPONSOR_LOGO_CACHE'] == '1' || !Rails.env.test?
    end

    def cache_refresh?
      ENV['REFRESH_CACHE'] == '1'
    end

    def cache_expired?(entry)
      Time.now.to_i - entry['fetched_at'] > cache_ttl_seconds
    end

    def cache_ttl_seconds
      (ENV['CACHE_TTL_MINUTES']&.to_i || DEFAULT_TTL_MINUTES) * 60
    end

    def read_entry(key)
      file = entry_path(key)
      return nil unless file.exist?

      JSON.parse(file.read)
    rescue JSON::ParserError
      nil
    end

    def entry_path(key)
      cache_dir.join("#{Digest::SHA1.hexdigest(key)}.json")
    end

    def cache_dir
      @cache_dir ||=
        Pathname.new(ENV['SPONSOR_LOGO_CACHE_DIR'] || Rails.root.join('tmp/cache/sponsor_logos'))
    end
  end
end
