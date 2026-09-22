class SitemapsController < ApplicationController
  def show
    # Crawler-facing endpoint; let CDNs absorb repeat fetches. The fragment
    # caches still bound the DB cost of a cache-miss render.
    expires_in 1.hour, public: true
    render xml: render_to_string(formats: [:xml])
  end
end
