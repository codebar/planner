class SponsorsController < ApplicationController
  def index
    @sponsors = Sponsor.active
  end
end
