# Restores sponsor logos that are missing from the S3 bucket by re-uploading
# copies of the original files from the Wayback Machine.
#
# The logos lived on the old SFTP-backed asset host (assets.codebar.io) until
# July 2025, when CarrierWave storage moved to S3 without migrating existing
# files. The Wayback Machine archived the asset host's files, so the original
# logo images can be recovered from it.
#
# Credentials and bucket are read from the same environment variables the
# CarrierWave initializer uses (AWS_ACCESS_KEY, AWS_SECRET_ACCESS_KEY,
# AWS_REGION, S3_BUCKET_NAME), so the task can run from any machine.
class SponsorLogoRestore
  Result = Data.define(:restored, :skipped, :failed)

  DEFAULT_SOURCE_URL = 'https://codebar.io/sponsors'.freeze
  PAGE_PATH_PATTERN = %r{/uploads/sponsor/(\d+)/([^/?#]+)}

  include Http
  include Wayback

  def self.call(source_url: ENV.fetch('SPONSORS_URL', DEFAULT_SOURCE_URL), s3_client: nil, delay: 1)
    new(s3_client:, delay:).call(source_url)
  end

  def initialize(s3_client: nil, delay: 1)
    @s3_client = s3_client
    @delay = delay
  end

  def call(source_url)
    logos = sponsor_logos(source_url)
    missing = logos.reject { |logo| logo_present?(logo) }
    index = missing.empty? ? {} : wayback_index
    restored, failed = restore(missing, index)
    Result.new(restored:, skipped: logos.size - missing.size, failed:)
  end

  private

  attr_reader :delay

  def sponsor_logos(source_url)
    Nokogiri::HTML(get!(source_url)).css('img').filter_map do |img|
      parse_page_path(img['src'])
    end.uniq
  end

  def parse_page_path(src)
    match = src&.match(PAGE_PATH_PATTERN)
    return unless match

    { sponsor_id: match[1].to_i, filename: decode(match[2]) }
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

  def restore(missing, index)
    restored = []
    failed = []
    missing.each do |logo|
      outcome = restore_one(logo, index)
      outcome.is_a?(Hash) ? failed << outcome : restored << logo
    end
    [restored, failed]
  end

  # Returns a Hash describing the failure, or anything else on success.
  def restore_one(logo, index)
    entry = index[[logo[:sponsor_id], logo[:filename].downcase]]
    return failure(logo, 'not found in Wayback Machine index') unless entry

    data = download_archive(entry)
    return failure(logo, 'archive download failed') if data.nil?

    upload_and_verify(logo, data)
  end

  def upload_and_verify(logo, data)
    s3_client.put_object(
      bucket:, key: s3_key(logo), body: data,
      content_type: content_type(logo[:filename]), acl: 'public-read'
    )
    return failure(logo, 'upload verification failed') unless logo_present?(logo)

    :restored
  rescue StandardError => e
    failure(logo, e.message)
  end

  def failure(logo, reason)
    { **logo, reason: }
  end

  def s3_key(logo)
    "uploads/sponsor/#{logo[:sponsor_id]}/#{logo[:filename]}"
  end

  def content_type(filename)
    case File.extname(filename).downcase
    when '.png' then 'image/png'
    when '.jpg', '.jpeg' then 'image/jpeg'
    when '.gif' then 'image/gif'
    when '.svg' then 'image/svg+xml'
    else 'application/octet-stream'
    end
  end

  def bucket
    ENV.fetch('S3_BUCKET_NAME', 'prod-sponsor-logos')
  end

  def region
    ENV.fetch('AWS_REGION', 'eu-north-1')
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region:,
      credentials: Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY'), ENV.fetch('AWS_SECRET_ACCESS_KEY'))
    )
  end
end
