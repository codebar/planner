class PortalController < ApplicationController
  before_action :is_member?

  def index
    @pending_jobs = current_member.jobs.where(submitted: false)
  end
end
