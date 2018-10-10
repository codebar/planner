class JobsController < ApplicationController
  def index
    @jobs = Job.active.approved.ordered
  end

  def show
    @job = Job.find(job_id)
    flash['alert'] = I18n.t('job.expired') if @job.expiry_date.past?
    redirect_to jobs_path unless @job.approved? && @job.submitted?
  end

  private

  def job_id
    params[:id]
  end
end
