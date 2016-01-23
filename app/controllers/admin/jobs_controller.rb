class Admin::JobsController < Admin::ApplicationController

  def index
    @jobs = Job.submitted.ordered
    authorize @jobs
  end

  def show
    @job = Job.find(params[:id])
    authorize @job
  end

  def all
    @jobs = Job.unscoped.ordered
    authorize @jobs
  end

  def approve
    authorize @job
    @job = Job.find(params[:job_id])
    @job.update_attribute(:approved, true)
    @job.update_attribute(:approved_by, current_user)

    JobMailer.job_approved(@job).deliver!

    flash[:notice] = "The job has been approved and an email has been sent out to #{@job.created_by.full_name} at #{@job.created_by.email}"

    redirect_to admin_jobs_path
  end
end
