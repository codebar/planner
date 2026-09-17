# Restores sponsor logos that are missing from the S3 bucket by re-uploading
# copies of the original files from the Wayback Machine.
#
# The logos lived on the old SFTP-backed asset host (assets.codebar.io) until
# July 2025, when CarrierWave storage moved to S3 without migrating existing
# files. The Wayback Machine archived the asset host's files, so the original
# logo images can be recovered from it.
#
# Credentials, bucket, and region come from the AWS_ASSETS constant
# (config/initializers/aws_assets.rb), which reads the same environment
# variables the CarrierWave initializer uses, so the task can run from any
# machine.
class SponsorLogoRestore
  Result = Data.define(:restored, :skipped, :failed, :rehearsed, :deferred)

  DEFAULT_SOURCE_URL = 'https://codebar.io/sponsors'.freeze
  PAGE_PATH_PATTERN = %r{/uploads/sponsor/(\d+)/([^/?#]+)}

  include Cache
  include Discovery
  include Http
  include Restorer
  include Wayback

  def self.call(source_url: ENV['SPONSORS_URL'] || DEFAULT_SOURCE_URL, s3_client: nil,
    delay: 1, retry_delay: Wayback::RETRY_DELAY, cdx_retry_delay: Wayback::CDX_RETRY_DELAY)
    new(s3_client:, delay:, retry_delay:, cdx_retry_delay:).call(source_url)
  end

  def initialize(s3_client: nil, delay: 1, retry_delay: Wayback::RETRY_DELAY, progress: nil,
    cdx_retry_delay: Wayback::CDX_RETRY_DELAY)
    @s3_client = s3_client
    @delay = delay
    @retry_delay = retry_delay
    @cdx_retry_delay = cdx_retry_delay
    @limit = ENV['RESTORE_LIMIT']&.to_i
    @dry_run = ENV['DRY_RUN'] == '1'
    @progress = progress || ->(message) { warn "[sponsor_logos] #{message}" }
  end

  def call(source_url)
    logos = sponsor_logos(source_url)
    report("Found #{logos.size} logo references on the page")
    missing, failed = classify(logos)
    missing, deferred = apply_limit(missing)
    run_restore(logos, missing, failed, deferred)
  end

  private

  attr_reader :delay, :retry_delay, :cdx_retry_delay, :limit, :dry_run

  def report(message)
    @progress.call(message)
  end

  # -> [batch to restore, deferred remainder]
  def apply_limit(missing)
    return [missing, []] unless limit&.positive?

    [missing.first(limit), missing.drop(limit)]
  end

  # An unavailable CDX index fails every missing logo instead of crashing.
  def run_restore(logos, missing, failed, deferred)
    index, index_error = load_index(missing)
    restore_set, index_failures = partition_unavailable(index, index_error, missing)
    restored, rehearsed, restore_failed = restore(restore_set, index || {})
    all_failed = failed + index_failures + restore_failed
    build_result(logos, restored, rehearsed, all_failed, deferred)
  end

  def build_result(logos, restored, rehearsed, all_failed, deferred)
    handled = restored.size + rehearsed.size + all_failed.size + deferred.size
    Result.new(restored:, rehearsed:, deferred:, skipped: logos.size - handled, failed: all_failed)
  end

  # -> [logos to restore, failure entries]; empty set when CDX is unavailable
  def partition_unavailable(_index, index_error, missing)
    return [missing, []] unless index_error

    [[], missing.map { |logo| failure(logo, index_error) }]
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
    AWS_ASSETS.fetch(:bucket)
  end

  def region
    AWS_ASSETS.fetch(:region)
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region:,
      credentials: Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY'), ENV.fetch('AWS_SECRET_ACCESS_KEY'))
    )
  end
end
