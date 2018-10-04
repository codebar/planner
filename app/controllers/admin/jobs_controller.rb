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

    @job.approve!(current_user)
    JobMailer.job_approved(@job).deliver_later
    flash[:notice] = I18n.t('admin.jobs.messages.approved', name: @job.created_by.full_name,
                                                            email: @job.created_by.email)

    redirect_to admin_jobs_path
  end
end
