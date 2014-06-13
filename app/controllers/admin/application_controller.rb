class Admin::ApplicationController < ApplicationController
  layout 'admin'

  include Pundit

  before_action :has_permissions?

  private

  def has_permissions?
    redirect_to root_path unless manager?
  end

  def jobs_pending_approval
    @jobs_pending_approval ||= Job.where(approved: false, submitted: true).count
  end

  helper_method :jobs_pending_approval
end
