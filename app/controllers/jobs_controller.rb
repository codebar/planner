class JobsController < ApplicationController
  before_filter :is_logged_in?
  before_filter :set_job, only: [:show, :preview, :edit, :update, :submit]
  before_filter :has_access?, only: [ :new, :create, :edit, :update, :submit]

  def index
    @jobs = Job.where(approved: true, submitted: true)
  end

  def pending
    @jobs = current_user.jobs.where(submitted: false)
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    @job.created_by_id = current_user.id
    if @job.save
      redirect_to job_preview_path(@job)
    else
      render 'new'
    end
  end

  def preview
  end

  def edit
  end

  def show
    redirect_to jobs_path unless @job.approved? and @job.submitted?
  end

  def submit
    @job.update_attribute(:submitted, true)

    flash[:notice] = "Job submitted. You will receive an email when the job has ben approved."
    redirect_to root_path
  end

  def update
    @job.update_attributes(job_params)
    redirect_to job_preview_path(@job)
  end

  private

  def job_params
    params.require(:job).permit(:title, :description, :location, :expiry_date, :email, :link_to_job, :company)
  end

  def set_job
    job_id = params[:job_id] || params[:id]
    @job = Job.find(job_id)
  end

  def has_access?
    redirect_to root_path unless logged_in? and is_verified_coach_or_admin?
  end
end
