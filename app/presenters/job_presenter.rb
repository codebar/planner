class JobPresenter < BasePresenter
  def published_on
    model.published_on.present? ? I18n.l(model.published_on, format: :date) : '-'
  end

  def published_on_time_iso8601
    model.published_on&.to_time&.iso8601
  end

  def link_to_job
    ActionController::Base.helpers.sanitize(model.link_to_job)
  end

  def location_or_remote
    model.remote ? I18n.t('job.location.remote') : model.location
  end
end
