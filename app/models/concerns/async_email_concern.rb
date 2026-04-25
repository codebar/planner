module AsyncEmailConcern
  extend ActiveSupport::Concern

  private

  def async_email_enabled?(chapter)
    return false if chapter.nil?
    return false if Rails.application.config.async_email_chapter_ids.empty?
    Rails.application.config.async_email_chapter_ids.include?(chapter.id)
  end
end