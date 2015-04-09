class EventPresenter < SimpleDelegator
  PRESENTER = { sessions: "WorkshopPresenter",
                course: "CoursePresenter",
                meeting: "MeetingPresenter",
                event: "EventPresenter" }


  def self.decorate_collection(collection)
    collection.map {|e| PRESENTER[e.class.to_s.downcase.to_sym].constantize.new(e) }
  end

  def chapter
    model.try(:chapter)
  end

  def venue
    model.venue
  end

  def sponsors
    model.sponsors
  end

  def invitable
    model.invitable || false
  end

  def description
    model.description rescue nil
  end

  def short_description
    model.short_description rescue model.description
  end

  def organisers
    @organisers ||= model.permissions.find_by_name("organiser").members rescue []
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

  def questionnaire(invitation)
    invitation.for_coach? ? coach_questionnaire : student_questionnaire
  end

  def admin_path
    Rails.application.routes.url_helpers.admin_event_path(model)
  end

  private

  def attendee_array
    model.attendances.map {|i| [i.member.full_name, i.role.upcase] }
  end

  def chapter_organisers
    model.chapter.permissions.find_by_name("organiser").members rescue []
  end

  def model
    __getobj__
  end
end
