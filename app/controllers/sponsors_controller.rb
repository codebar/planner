class SponsorsController < ApplicationController
  def index
    @sponsors = Sponsor.active.uniq
  end
end
