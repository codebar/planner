class SponsorsController < ApplicationController
  def index
    @sponsors = Sponsor.all
  end
end
