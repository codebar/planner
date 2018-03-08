class SponsorsController < ApplicationController
  def index
    @sponsor_levels = Sponsor.active.group_by(&:level)
  end
end
