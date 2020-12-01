class EventPresenter < BasePresenter
  PRESENTER = { workshop: 'WorkshopPresenter',
                course: 'CoursePresenter',
                meeting: 'MeetingPresenter',
                event: 'EventPresenter' }.freeze

  def self.decorate(event)
    PRESENTER[event.class.to_s.downcase.to_sym].constantize.new(event)
  end

  def self.decorate_collection(collection)
    collection.map { |event| decorate(event) }
  end

  def chapter
    model.try(:chapter)
  end

  delegate :venue, :sponsors, to: :model

  def invitable
    model.invitable || false
  end

  def description
    model&.description
  end

  def short_description
    model.respond_to?(:short_description) ? model.short_description : description
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser')&.members || []
  end

  def month
    I18n.l(model.date_and_time, format: :month).upcase
  end

  def time
    formatted_time = start_time
    formatted_time << " - #{end_time}" if model.ends_at
    formatted_time << " #{I18n.l(model.date_and_time, format: :time_zone)}"
  end

  def start_time
    I18n.l(model.date_and_time, format: :time)
  end

  def end_time
    I18n.l(model.ends_at, format: :time)
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

  def spaces?
    coach_spaces? || student_spaces?
  end

  def coach_spaces?
    venue.present? && (venue.coach_spots > attending_coaches.length)
  end

  def student_spaces?
    venue.present? && (venue.seats > attending_students.length)
  end

  def event_coach_spaces?
    model.coach_spaces?
  end

  def event_student_spaces?
    model.student_spaces?
  end

  def attendees_csv
    generate_csv_from_array(attendee_array)
  end

  def day_temporal_pronoun
    model.date_and_time.today? ? 'today' : 'tomorrow'
  end

  def rsvp_closing_date_and_time
    model.date_and_time - 3.5.hours
  end

  private

  def generate_csv_from_array(attendees)
    CSV.generate { |csv| attendees.each { |a| csv << a } }
  end

  def attendee_array
    model.attendances.map { |i| [i.member.full_name, i.role.upcase] }
  end
end
