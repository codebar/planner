class SponsorsController < ApplicationController
  def index
    # v2: bump when the sponsors view or partials change, otherwise a deploy
    # keeps serving the cached fragment until the next sponsor save.
    # Only the level listings are cached; the layout renders fresh so asset
    # URLs and meta tags are never stale.
    key = "sponsors/index/v2/#{Sponsor.active.maximum(:updated_at)&.to_fs(:usec)}"
    @sponsor_levels_html = Rails.cache.fetch(key) do
      render_to_string(
        partial: 'sponsor_levels',
        locals: { sponsor_levels: Sponsor.active.group_by(&:level) }
      )
    end
  end
end
