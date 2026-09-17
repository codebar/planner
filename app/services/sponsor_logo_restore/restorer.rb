class SponsorLogoRestore
  # Drives the per-logo restore pipeline and buckets each outcome.
  module Restorer
    def restore(missing, index)
      buckets = Hash.new { |h, k| h[k] = [] }
      missing.each_with_index do |logo, i|
        restore_tick(index: i, total: missing.size)
        bucket, outcome = restore_one(logo, index)
        buckets[bucket] << outcome
      end
      [buckets[:restored], buckets[:rehearsed], buckets[:failed]]
    end

    private

    def restore_tick(index:, total:)
      report("Restore progress: #{index + 1}/#{total}") if ((index + 1) % 10).zero? || index + 1 == total
    end

    # -> [:restored, logo], [:rehearsed, logo], or [:failed, failure hash].
    def restore_one(logo, index)
      entry = index[[logo[:sponsor_id], logo[:filename].downcase]]
      return [:failed, failure(logo, 'not found in Wayback Machine index')] unless entry

      data = download_archive(entry)
      return [:failed, failure(logo, 'archive download failed')] if data.nil?
      return [:rehearsed, logo] if dry_run

      upload_and_verify(logo, data)
    end

    def upload_and_verify(logo, data)
      s3_client.put_object(
        bucket:, key: s3_key(logo), body: data,
        content_type: content_type(logo[:filename]), acl: 'public-read'
      )
      return [:failed, failure(logo, 'upload verification failed')] unless logo_present?(logo)

      [:restored, logo]
    rescue StandardError => e
      [:failed, failure(logo, e.message)]
    end
  end
end
