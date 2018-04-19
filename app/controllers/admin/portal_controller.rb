class Admin::PortalController < Admin::ApplicationController
  def index
    authorize :admin_portal

    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
    @sponsors = Sponsor.last(5)
    @chapters = Chapter.all
    @workshops = Workshop.upcoming
    @groups = Group.includes(:chapter)
    @subscribers = Subscription.order('created_at DESC').limit(20).includes(:member, :group)
  end

  def guide
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, hard_wrap: true)
  end
end
