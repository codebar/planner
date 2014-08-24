class FeedbackRequestMailer  < ActionMailer::Base
  include EmailHeaderHelper

  helper ApplicationHelper

  def request_feedback sessions, member, feedback_request
    @session = sessions
    @host_address = AddressDecorator.decorate(@session.host.address)
    @member = member
    @feedback_request = feedback_request

    subject = "Workshop Feedback for #{l(@session.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
