class WorkshopPresenter < EventPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ActionView::Helpers::DateHelper

  PAIRING_HEADINGS = ['New attendee', 'Name', 'Role', 'Tutorial', 'Note', 'Skills'].freeze

  def self.decorate(workshop)
    return VirtualWorkshopPresenter.new(workshop) if workshop.virtual?

    WorkshopPresenter.new(workshop)
  end

  def title
    I18n.t('workshops.title', host: venue.name)
  end

  def address
    AddressPresenter.new(venue.address)
  end

  def attending_and_available_student_spots
    "#{attending_students.count}/#{student_spaces}"
  end

  def attending_and_available_coach_spots
    "#{attending_coaches.count}/#{coach_spaces}"
  end

  def venue
    model.host
  end

  def organisers
    @organisers ||= model.permissions&.find_by(name: 'organiser')&.members || chapter_organisers
  end

  def attendees_checklist
    "Students\n\n" + students_checklist + "\n\n\n\nCoaches\n\n" + coaches_checklist
  end

  def attendees_emails
    Member.joins(:workshop_invitations)
          .where('workshop_invitations.workshop_id = ? and attending =?', model.id, true)
          .pluck(:email).join(', ')
  end

  def path
    Rails.application.routes.url_helpers.workshop_path(model)
  end

  def admin_path
    Rails.application.routes.url_helpers.admin_workshop_path(model)
  end

  def distance_of_time
    return "(#{distance_of_time_in_words_to_now(date_and_time)} ago)" if past?

    "(in #{distance_of_time_in_words_to_now(date_and_time)})"
  end

  def send_attending_email(invitation, waitinglist = false)
    WorkshopInvitationMailer.attending(model, invitation.member, invitation, waitinglist).deliver_now
  end

  def coach_spaces
    venue.coach_spots
  end

  def student_spaces
    venue.seats
  end

  def pairing_csv
    pairing_details = model.attendances.inject([PAIRING_HEADINGS]) do |content, invitation|
      member = MemberPresenter.new(invitation.member)
      content << member.pairing_details_array(invitation.role, invitation.tutorial, invitation.note)
    end
    generate_csv_from_array(pairing_details)
  end

  private

  def students_checklist
    model.attending_students.each_with_index.map do |a, pos|
      "#{member_info(a.member, pos)}\t\t\t#{note(a)}"
    end.join("\n\n")
  end

  def coaches_checklist
    model.attending_coaches.each_with_index.map do |invitation, pos|
      member_info(invitation.member, pos).to_s
    end.join("\n\n")
  end

  def attending_organisers
    organisers.map { |organiser| [organiser.full_name, 'ORGANISER'] }
  end

  def attendee_array
    model.attendances.map do |invitation|
      map_member_details(organisers, invitation.member, invitation.role)
    end.concat(attending_organisers).uniq
  end

  def member_info(member, pos)
    "#{MemberPresenter.new(member).newbie? ? 'I__' : '___'} #{pos + 1}.\t #{member.full_name}"
  end

  def note(invitation)
    invitation.note || '__________________________'
  end

  def map_member_details(organisers, member, role)
    organisers.include?(member) ? [member.full_name, 'ORGANISER'] : [member.full_name, role.upcase]
  end
end
