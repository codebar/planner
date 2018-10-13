class JobsController < ApplicationController
  def index
    @jobs = Job.published.active.ordered
  end

  def show
    @job = Job.friendly.find(job_id)

    redirect_to jobs_path unless @job.approved? && @job.submitted?
  end

  private

  def job_id
    params[:id]
  end
end
