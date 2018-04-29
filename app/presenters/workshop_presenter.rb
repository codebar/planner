class WorkshopPresenter < EventPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::DateHelper

  def venue
    model.host
  end

  def organisers
    @organisers ||= model.permissions.find_by(name: 'organiser').members rescue chapter_organisers
  end

  # Gets an HTML list of the organisers, with mobile numbers if the event's
  # not past and the user's logged in.
  def organisers_as_list(logged_in = false)
    list = organisers.shuffle.map do |o|
      organiser = ActionController::Base.helpers.link_to(o.full_name, o.twitter_url)
      organiser << " - #{o.mobile}" if logged_in && model.future? && o.mobile
      content_tag(:li, organiser)
    end.join.html_safe
    if list.blank?
      list = content_tag(:li, 'Nobody yet')
    end
    content_tag(:ul, list)
  end

  def attendees_csv
    CSV.generate { |csv| attendee_array.each { |a| csv << a } }
  end

  def attendees_checklist
    "Students\n\n" + students_checklist + "\n\n\n\nCoaches\n\n" + coaches_checklist
  end

  def attendees_emails
    model.attendances.map { |m| m.member.email if m.member }.compact.join(', ')
  end

  def time
    I18n.l(model.time, format: :time)
  end

  def path
    Rails.application.routes.url_helpers.workshop_path(model)
  end

  def admin_path
    Rails.application.routes.url_helpers.admin_workshop_path(model)
  end

  def distance_of_time
    past? ? "(#{distance_of_time_in_words_to_now(date_and_time)} ago)" :
            "(in #{distance_of_time_in_words_to_now(date_and_time)})"
  end

  private

  def students_checklist
    model.attending_students.order('note asc').each_with_index.map do |a, pos|
      "#{member_info(a.member, pos)}\t\t\t#{note(a)}"
    end.join("\n\n")
  end

  def coaches_checklist
    model.attending_coaches.each_with_index.map do |a, pos|
      member_info(a.member, pos).to_s
    end.join("\n\n")
  end

  def attending_organisers
    organisers.map do |o|
      [o.full_name, 'ORGANISER']
    end
  end

  def attendee_array
    model.attendances.map do |i|
      if organisers.include?(i.member)
        [i.member.full_name, 'ORGANISER']
      else
        [i.member.full_name, i.role.upcase]
      end
    end.concat(attending_organisers).uniq
  end

  def model
    __getobj__
  end

  def member_info(member, pos)
    "#{MemberPresenter.new(member).newbie? ? "I__" : "___"} #{pos + 1}.\t #{member.full_name}"
  end

  def note(invitation)
    "#{invitation.note.present? ? invitation.note : "__________________________"} "
  end
end
