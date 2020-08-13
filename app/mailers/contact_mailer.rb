class ContactMailer < ActionMailer::Base
  include EmailHeaderHelper

  helper ApplicationHelper
  helper EmailHelper

  def subscription_notification(contact)
    @contact = contact

    subject = "You have been added to codebar's sponsors mailing list"

    mail(mail_args(contact, subject, 'no-reply@codebar.io'), &:html)
  end
end
