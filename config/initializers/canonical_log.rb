# frozen_string_literal: true

# Adds the matched route template to the request-completion log payload so
# canonical log lines carry a normalized path: no record IDs, no query string.
# Example: "/workshops/:id(.:format)". Unmatched routes are rejected by the
# router before any controller runs, so they emit no Completed line at all.
module CanonicalLogPathTemplate
  def append_info_to_payload(payload)
    super
    payload[:path_template] = request.route_uri_pattern
  end
end

ActionController::Base.prepend(CanonicalLogPathTemplate)
