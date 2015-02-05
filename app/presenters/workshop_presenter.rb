class WorkshopPresenter < EventPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def venue
    model.host
  end

  def organisers
    @organisers ||= model.permissions.find_by_name("organiser").members rescue chapter_organisers
  end

  # Gets an HTML list of the organisers, with mobile numbers if the event's
  # not past and the user's logged in.
  def organisers_as_list(logged_in=false)
    list = organisers.shuffle.map do |o|
      organiser = ActionController::Base.helpers.link_to(o.full_name, o.twitter_url)
      organiser << " - #{o.mobile}" if logged_in && model.future? && o.mobile
      content_tag(:li, organiser)
    end.join.html_safe
    if list.blank?
      list = content_tag(:li, "Nobody yet")
    end
    content_tag(:ul, list)
  end

  def attendees_csv
    CSV.generate {|csv| attendee_array.each { |a| csv << a } }
  end

  def time
    I18n.l(model.time, format: :time)
  end

  def path
    Rails.application.routes.url_helpers.workshop_path(model)
  end

  private

  def attendee_array
    model.attendances.map {|i| [i.member.full_name, i.role.upcase] }
  end

  def model
    __getobj__
  end
end
