class JobsController < ApplicationController
  def index
    jobs = Job.published.active.ordered
    @jobs = JobsPresenter.new(jobs)
  end

  def show
    job = Job.friendly.published.find(job_id)
    @job = JobPresenter.new(job)
  end

  private

  def job_id
    params[:id]
  end
end
