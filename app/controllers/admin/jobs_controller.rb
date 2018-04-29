class Admin::JobsController < Admin::ApplicationController
  def index
    @jobs = Job.submitted.ordered
    authorize @jobs
  end

  def show
    @job = Job.unscoped.find(params[:id])
    authorize @job
  end

  def all
    @jobs = Job.unscoped.ordered.includes(:approved_by)
    authorize @jobs
  end

  def approve
    @job = Job.find(params[:job_id])
    authorize @job

    @job.update_attributes(approved: true, approved_by_id: current_user.id)

    JobMailer.job_approved(@job).deliver_now

    flash[:notice] = "The job has been approved and an email has been sent out to " \
                     "#{@job.created_by.full_name} at #{@job.created_by.email}"

    redirect_to admin_jobs_path
  end
end
