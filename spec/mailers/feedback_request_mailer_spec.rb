require "spec_helper"

describe FeedbackRequestMailer do

  let(:email) { ActionMailer::Base.deliveries.last }
  let(:session) { Fabricate(:sessions, title: "HTML & CSS") }
  let(:member) { Fabricate(:member) }
  let(:feedback_request) { Fabricate(:feedback_request, sessions: session, member: member) }

  it "#request_feedback" do
    email_subject = "Feedback for Codebar workshop - #{I18n.l(session.date_and_time, format: :email_title)}"

    FeedbackRequestMailer.request_feedback(session, member, feedback_request).deliver

    expect(email.subject).to eq(email_subject)
  end
end
