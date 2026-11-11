class Admin::PortalController < Admin::ApplicationController
  def index
    authorize :admin_portal

    @chapters = Chapter.active.all.order(name: :asc)
    @workshops = Workshop.upcoming
  end

  def guide; end
end
