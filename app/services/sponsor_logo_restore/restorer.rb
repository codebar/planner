class SponsorLogoRestore
  # Drives the per-logo restore pipeline and buckets each outcome.
  module Restorer
    def restore(missing, index)
      buckets = Hash.new { |h, k| h[k] = [] }
      missing.each_with_index do |logo, i|
        restore_tick(index: i, total: missing.size)
        bucket, outcome = restore_one_safe(logo, index)
        buckets[bucket] << outcome
      end
      [buckets[:restored], buckets[:rehearsed], buckets[:failed]]
    end

    private

    # A network exception mid-download must not abort the batch; record the
    # logo as failed and carry on.
    def restore_one_safe(logo, index)
      restore_one(logo, index)
    rescue StandardError => e
      [:failed, failure(logo, e.message)]
    end

    def restore_tick(index:, total:)
      report("Restore progress: #{index + 1}/#{total}") if ((index + 1) % 10).zero? || index + 1 == total
    end

    # Exact filename first; the CarrierWave thumb version is the fallback —
    # the old host's final crawl stored 522 error pages for some originals,
    # while their thumb variants were captured intact months earlier. A bad
    # exact capture loses to a good thumb; anything beats nothing.
    def index_entry(index, logo)
      exact = index[[logo[:sponsor_id], logo[:filename].downcase]]
      return exact if good_capture?(exact)

      thumb = index[[logo[:sponsor_id], "thumb_#{logo[:filename]}".downcase]]
      good_capture?(thumb) ? thumb : (exact || thumb)
    end

    # -> [:restored, logo], [:rehearsed, logo], or [:failed, failure hash].
    def restore_one(logo, index)
      entry = index_entry(index, logo)
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

      # A verified restore means the logo is present; refresh the availability
      # cache so later runs do not re-attempt it while the stale '403' lives on.
      cache_write("availability:#{public_url(logo)}", '200')
      [:restored, logo]
    rescue StandardError => e
      [:failed, failure(logo, e.message)]
    end
  end
end
