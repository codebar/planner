class Admin::JobsController < Admin::ApplicationController

  def index
    @jobs = Job.where(approved: false, submitted: true).order('created_at ASC')
  end

  def show
    @job = Job.find(params[:id])
  end

  def approve
    @job = Job.find(params[:job_id])
    @job.update_attribute(:approved, true)

    flash[:notice] = "Job #{@job.title} at #{@job.company} has been approved"

    redirect_to admin_jobs_path
  end
end
