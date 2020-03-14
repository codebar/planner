class VirtualWorkshopInvitationMailer < ActionMailer::Base
  include EmailHelper
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper
  helper EmailHelper

  def attending(workshop, member, invitation, waiting_list = false)
    @workshop = VirtualWorkshopPresenter.new(workshop)
    @member = member
    @invitation = invitation
    @waiting_list = waiting_list

    subject = "Attendance Confirmation: #{I18n.t('workshop.virtual.title',
                                                 chapter: @workshop.chapter.name,
                                                 date: humanize_date(@workshop.date_and_time))}"

    mail(mail_args(member, subject, @workshop.chapter.email), &:html)
  end
end
