class SponsorsController < ApplicationController
  def index
    # v1: bump when the sponsors view or partials change, otherwise a deploy
    # keeps serving the cached body until the next sponsor save.
    key = "sponsors/index/v1/#{Sponsor.active.maximum(:updated_at)&.to_fs(:usec)}"
    @sponsor_levels = Sponsor.active.group_by(&:level)
    body = Rails.cache.fetch(key) { render_to_string(layout: false) }
    # body is markup rendered by this app's own template, not user input
    render html: body.html_safe # rubocop:disable Rails/OutputSafety
  end
end
