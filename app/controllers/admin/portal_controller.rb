class Admin::PortalController < Admin::ApplicationController

  def index
    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
    @sponsors = Sponsor.all
    @chapters = Chapter.all
    @workshops = Sessions.upcoming
    @groups = Group.all
  end
end
