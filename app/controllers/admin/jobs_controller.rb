class Admin::JobsController < Admin::ApplicationController
  def index
    @jobs = Job.where(submitted: true)
               .order(created_at: :desc)
               .paginate(page: page)
    authorize @jobs
  end

  def show
    @job = Job.unscoped.find(params[:id])
    authorize @job
  end

  def approve
    @job = Job.submitted.find(params[:job_id])
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
