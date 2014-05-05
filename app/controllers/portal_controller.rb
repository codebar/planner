class PortalController < ApplicationController
  before_action :logged_in?

  def index
    @pending_jobs = current_member.jobs.where(submitted: false)
  end
end
