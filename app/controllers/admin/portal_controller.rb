class Admin::PortalController < Admin::ApplicationController
  def index
    authorize :admin_portal

    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
    @chapters = Chapter.active.all.order(name: :asc)
    @workshops = Workshop.upcoming
    @groups = Group.joins(:chapter).merge(@chapters)
    @subscribers = Subscription.joins(:chapter).merge(@chapters)
                               .ordered.limit(20).includes(:member, :group)
  end

  def guide; end
end
