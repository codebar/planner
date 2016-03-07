class Admin::PortalController < Admin::ApplicationController

  def index
    redirect_to root_path, notice: "You can't be here" unless logged_in? and current_user.has_role?(:admin)

    @jobs_pending_approval = Job.where(approved: false, submitted: true).count
    @sponsors = Sponsor.last(5)
    @chapters = Chapter.all
    @workshops = Workshop.upcoming
    @groups = Group.all
    @subscribers = Subscription.last(20).reverse
  end

  def guide
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, hard_wrap: true)
  end
end
