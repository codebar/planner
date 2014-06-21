class PortalController < ApplicationController
  before_action :is_member?

  def index
    @pending_jobs = current_user.jobs.where(submitted: false)
  end
end
