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

    JobMailer.job_approved(@job).deliver!

    flash[:notice] = "Job #{@job.title} at #{@job.company} has been approved and #{@job.created_by.full_name} has been sent an email."

    redirect_to admin_jobs_path
  end
end
