module EmailDelivery
  extend ActiveSupport::Concern

    private

    def log_sent_email
      member = params[:member]
      return unless member

      MemberEmailDelivery.create!(
        member: member,
        subject: mail.subject,
        body: mail.body.to_s,
        to: mail.to,
        cc: mail.cc,
        bcc: mail.bcc
      )
    end
end
