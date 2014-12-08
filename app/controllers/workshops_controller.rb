class WorkshopsController < ApplicationController
  def show
    @workshop = WorkshopPresenter.new(Sessions.find(params[:id]))
  end
end
