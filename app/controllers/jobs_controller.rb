class JobsController < ApplicationController
  def index
    @jobs = Job.active.approved.ordered
  end

  def show
    @job = Job.find(job_id)
    redirect_to jobs_path unless @job.approved? && @job.submitted?
  end

  private

  def job_id
    params[:id]
  end
end
