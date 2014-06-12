class Admin::ApplicationController < ApplicationController
  include Pundit

  layout 'admin'

  def jobs_pending_approval
    @jobs_pending_approval ||= Job.where(approved: false, submitted: true).count
  end

  helper_method :jobs_pending_approval
end
