class FeedbackRequestMailer < ActionMailer::Base
  include EmailHeaderHelper

  helper ApplicationHelper

  def request_feedback(workshops, member, feedback_request)
    @workshop = workshops
    @host_address = AddressPresenter.new(@workshop.host.address)
    @member = member
    @feedback_request = feedback_request

    subject = "Workshop Feedback for #{l(@workshop.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end
end
