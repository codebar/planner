class Admin::ApplicationController < ApplicationController
  layout 'admin'
  before_action :is_admin?

  def is_admin?
    redirect_to root_path, notice: "You can't be there" unless logged_in? and current_member.is_admin?
  end

  def jobs_pending_approval
    @jobs_pending_approval ||= Job.where(approved: false, submitted: true).count
  end

  helper_method :jobs_pending_approval
end
