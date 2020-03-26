class Admin::PortalController < Admin::ApplicationController
  def index
    authorize :admin_portal

    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
    @chapters = Chapter.active.all.order(name: :asc)
    @workshops = Workshop.includes(:chapter).upcoming
    @groups = Group.joins(:chapter).merge(@chapters)
    @subscribers = Subscription.joins(:chapter).merge(@chapters)
                               .ordered.limit(20).includes(:member, :group)
  end

  def guide
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, hard_wrap: true)
  end
end
