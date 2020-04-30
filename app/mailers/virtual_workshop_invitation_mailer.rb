class VirtualWorkshopInvitationMailer < ActionMailer::Base
  include EmailHelper
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper
  helper EmailHelper

  def attending(workshop, member, invitation, waiting_list = false)
    setup(workshop, invitation, member)
    @waiting_list = waiting_list

    subject = "Attendance Confirmation: #{I18n.t('workshop.virtual.title',
                                                 chapter: @workshop.chapter.name,
                                                 date: humanize_date(@workshop.date_and_time))}"

    attachments['codebar.ics'] = { mime_type: 'text/calendar',
                                   content: WorkshopCalendar.new(workshop, invitation_url(invitation)).calendar.to_ical }
    mail(mail_args(member, subject, @workshop.chapter.email), &:html)
  end

  def attending_reminder(workshop, member, invitation)
    setup(workshop, invitation, member)
    subject = t('mailer.workshop_invitation.virtual.attending_reminder.subject',
                date_time: humanize_date(workshop.date_and_time, with_time: true))

    mail(mail_args(member, subject, @workshop.chapter.email), &:html)
  end

  def invite_coach(workshop, member, invitation)
    setup(workshop, invitation, member)
    subject = t('mailer.workshop_invitation.virtual.invite_coach.subject',
                date_time: humanize_date(@workshop.date_and_time, with_time: true))

    mail(mail_args(member, subject, 'no-reply@codebar.io'), &:html)
  end

  def invite_student(workshop, member, invitation)
    setup(workshop, invitation, member)
    subject = t('mailer.workshop_invitation.virtual.invite_student.subject',
                date_time: humanize_date(@workshop.date_and_time, with_time: true))

    mail(mail_args(member, subject, 'no-reply@codebar.io'), &:html)
  end

  def waiting_list_reminder(workshop, member, invitation)
    setup(workshop, invitation, member)
    subject = t('mailer.workshop_invitation.waiting_list_reminder.subject',
                date_time: humanize_date(workshop.date_and_time, with_time: true))

    mail(mail_args(member, subject, @workshop.chapter.email), &:html)
  end

  private

  def setup(workshop, invitation, member)
    @workshop = workshop
    @member = member
    @invitation = invitation
  end
end
