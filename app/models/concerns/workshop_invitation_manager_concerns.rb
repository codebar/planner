module WorkshopInvitationManagerConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    def send_workshop_attendance_reminders(workshop)
      workshop_mailer = workshop.virtual? ? VirtualWorkshopInvitationMailer : WorkshopInvitationMailer
      workshop.attendances.not_reminded.each do |invitation|
        workshop_mailer.send(:attending_reminder, workshop, invitation.member, invitation).deliver_now
        invitation.update(reminded_at: Time.zone.now)
      end
    end
    handle_asynchronously :send_workshop_attendance_reminders

    def send_workshop_emails(workshop, audience)
      return 'The workshop is not invitable' unless workshop.invitable?

      invite_students_to_workshop(workshop) if audience.in?(%w[students everyone])
      invite_coaches_to_workshop(workshop) if audience.in?(%w[coaches everyone])
    end
    handle_asynchronously :send_workshop_emails

    def send_virtual_workshop_emails(workshop, audience)
      return 'The workshop is not invitable' unless workshop.invitable?

      invite_students_to_virtual_workshop(workshop) if audience.in?(%w[students everyone])
      invite_coaches_to_virtual_workshop(workshop) if audience.in?(%w[coaches everyone])
    end
    handle_asynchronously :send_virtual_workshop_emails

    def send_waiting_list_emails(workshop)
      workshop = WorkshopPresenter.decorate(workshop)

      retrieve_and_notify_waitlisted(role: 'Coach') if workshop.coach_spaces?
      retrieve_and_notify_waitlisted(role: 'Student') if workshop.student_spaces?
    end
    handle_asynchronously :send_waiting_list_emails

    def send_workshop_waiting_list_reminders(workshop)
      workshop_mailer = workshop.virtual? ? VirtualWorkshopInvitationMailer : WorkshopInvitationMailer
      workshop.invitations.on_waiting_list.not_reminded.each do |invitation|
        workshop_mailer.send(:waiting_list_reminder, workshop, invitation.member, invitation).deliver_now
        invitation.update(reminded_at: Time.zone.now)
      end
    end
    handle_asynchronously :send_workshop_waiting_list_reminders

    private

    def create_invitation(workshop, member, role)
      invitation = WorkshopInvitation.create(workshop: workshop, member: member, role: role)
      invitation.persisted? ? invitation : nil
    end

    def invite_coaches_to_virtual_workshop(workshop)
      chapter_coaches(workshop.chapter).shuffle.each do |coach|
        invitation = create_invitation(workshop, coach, 'Coach') || next
        VirtualWorkshopInvitationMailer.invite_coach(workshop, coach, invitation).deliver_now
      end
    end

    def invite_coaches_to_workshop(workshop)
      chapter_coaches(workshop.chapter).shuffle.each do |coach|
        invitation = create_invitation(workshop, coach, 'Coach') || next
        WorkshopInvitationMailer.invite_coach(workshop, coach, invitation).deliver_now
      end
    end

    def invite_students_to_virtual_workshop(workshop)
      chapter_students(workshop.chapter).shuffle.each do |student|
        invitation = create_invitation(workshop, student, 'Student') || next
        VirtualWorkshopInvitationMailer.invite_student(workshop, student, invitation).deliver_now
      end
    end

    def invite_students_to_workshop(workshop)
      chapter_students(workshop.chapter).shuffle.each do |student|
        invitation = create_invitation(workshop, student, 'Student') || next
        WorkshopInvitationMailer.invite_student(workshop, student, invitation).deliver_now
      end
    end

    def retrieve_and_notify_waitlisted(role:)
      WaitingList.by_workshop(workshop).where_role(role).each do |waiting_list|
        WorkshopInvitationMailer.notify_waiting_list(waiting_list.invitation).deliver_now
        waiting_list.destroy
      end
    end
  end
end
