class Admin::PortalController < Admin::ApplicationController

  def index
    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
    @sponsors = Sponsor.last(5)
    @chapters = Chapter.all
    @workshops = Sessions.upcoming
    @groups = Group.all
  end
end
