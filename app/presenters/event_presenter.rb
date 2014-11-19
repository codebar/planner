class EventPresenter < SimpleDelegator
  PRESENTER = { sessions: "WorkshopPresenter",
                course: "CoursePresenter",
                meeting: "MeetingPresenter" }


  def self.decorate_collection(collection)
    collection.map {|e| PRESENTER[e.class.to_s.downcase.to_sym].constantize.new(e) }
  end

  def venue
    model.venue
  end

  def sponsors
    model.sponsors
  end

  def description
    nil
  end

  def organisers
    @organisers ||= []
  end

  # Gets an HTML list of the organisers, with mobile numbers if the event's
  # not past and the user's logged in.
  def organisers_as_list
    list = organisers.shuffle.map do |o|
      item = "<li>".html_safe
      item << link_to(o.full_name, twitter_url_for(o))
      item << "- #{o.mobile}" if logged_in? && model.future?
      item << "</li>".html_safe
    end.join
    if list.blank?
      list = "<li>Nobody yet</li>".html_safe
    end
    "<ul>".html_safe << list << "</ul>".html_safe
  end

  def month
    I18n.l(model.date_and_time, format: :month).upcase
  end

  def time
    I18n.l(model.date_and_time, format: :time)
  end

  def path
    model
  end

  def class_string
    model.class.to_s.downcase
  end

  private

  def attendee_array
    model.attendances.map {|i| [i.member.full_name, i.role.upcase] }
  end

  def model
    __getobj__
  end
end
