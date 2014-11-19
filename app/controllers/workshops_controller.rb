class WorkshopsController < ApplicationController
  def show
    @workshop = EventPresenter.new(Sessions.find(params[:id]))
  end
end
