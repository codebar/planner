# frozen_string_literal: true

# Adds the matched route template to the request-completion log payload so
# canonical log lines carry a normalized path: no record IDs, no query string.
# Example: "/workshops/:id(.:format)". Unmatched routes are rejected by the
# router before any controller runs, so they emit no Completed line at all.
# Also carries the puma process resident set size (rss_mb, from VmRSS) so drift
# toward the dyno memory quota is visible in Loki; nil off Linux (/proc absent).
module CanonicalLogPathTemplate
  STATUS_AVAILABLE = File.exist?('/proc/self/status')

  def append_info_to_payload(payload)
    super
    payload[:path_template] = request.route_uri_pattern
    payload[:rss_mb] = process_rss_mb
  end

  private

  def process_rss_mb
    return unless STATUS_AVAILABLE

    line = File.foreach('/proc/self/status').find { |l| l.start_with?('VmRSS:') }
    return unless line

    (line.scan(/\d+/).first.to_f / 1024).round(1)
  rescue StandardError
    nil
  end
end

ActionController::Base.prepend(CanonicalLogPathTemplate)
