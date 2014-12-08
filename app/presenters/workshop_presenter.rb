class WorkshopPresenter < EventPresenter

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
      item = "<li>".html_safe
      item << ActionController::Base.helpers.link_to(o.full_name, o.twitter_url)
      item << "- #{o.mobile}" if logged_in && model.future?
      item << "</li>".html_safe
    end.join
    if list.blank?
      list = "<li>Nobody yet</li>".html_safe
    end
    "<ul>".html_safe << list << "</ul>".html_safe
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
