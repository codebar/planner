class Member::JobsController < ApplicationController
  before_action :set_current_user_job, only: %i[preview edit update submit]
  before_action :is_logged_in?

  def index
    @jobs = current_user.jobs
                        .owner_order
                        .paginate(page: page)
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    @job.created_by_id = current_user.id
    if @job.save
      redirect_to member_job_preview_path(@job)
    else
      flash['notice'] = @job.errors.full_messages.join('<br>')
      render 'new'
    end
  end

  def show; end

  def edit
    redirect_to member_jobs_path, notice: 'You cannot edit a job that has already been approved.' if @job.approved?
  end

  def submit
    @job.update_attributes(submitted: true)

    flash[:notice] = 'Job submitted. You will receive an email when the job has ben approved.'
    redirect_to member_jobs_path
  end

  def update
    if @job.update_attributes(job_params)
      redirect_to member_job_preview_path(@job), notice: 'The job has been updated'
    else
      flash['notice'] = @job.errors.full_messages.join('<br>')
      render 'edit'
    end
  end

  private

  def job_params
    params.require(:job).permit(:title, :description, :location, :expiry_date, :email, :link_to_job,
                                :company, :company_website, :company_address, :company_postcode,
                                :remote, :salary)
  end

  def set_current_user_job
    job_id = params[:job_id] || params[:id]
    @job = current_user.jobs.find(job_id)
  end
end
