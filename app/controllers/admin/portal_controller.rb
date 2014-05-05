class Admin::PortalController < Admin::ApplicationController

  def index
    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
  end
end
