class ContactMailer < ApplicationMailer
  include EmailHeaderHelper

  helper ApplicationHelper

  def subscription_notification(contact)
    @contact = contact

    subject = "You have been added to codebar's sponsors mailing list"

    mail_to_member(contact, subject, 'no-reply@codebar.io', &:html)
  end
end
