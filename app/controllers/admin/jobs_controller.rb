class Admin::JobsController < Admin::ApplicationController
  def index
    jobs = Job.pending_or_published
              .order(created_at: :desc)
              .paginate(page: page)
    authorize jobs
    @jobs = JobsPresenter.new(jobs)
  end

  def show
    job = Job.find(params[:id])
    authorize job
    @job = JobPresenter.new(job)
  end

  def approve
    @job = Job.pending.find(params[:job_id])
    authorize @job

    @job.approve!(current_user)
    JobMailer.job_approved(@job).deliver_later
    flash[:notice] = I18n.t('admin.jobs.messages.approved', name: @job.created_by.full_name,
                                                            email: @job.created_by.email)

    redirect_to admin_jobs_path
  end

  def page
    params.permit(:page)[:page]
  end
end
