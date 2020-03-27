class Admin::PortalController < Admin::ApplicationController
  def index
    authorize :admin_portal

    @portal = AdminPortalPresenter.new
  end

  def guide
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, hard_wrap: true)
  end
end
