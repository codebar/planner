require 'spec_helper'

describe FeedbackRequestMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:workshop) { Fabricate(:workshop, title: 'HTML & CSS') }
  let(:member) { Fabricate(:member) }
  let(:feedback_request) { Fabricate(:feedback_request, workshop: workshop, member: member) }

  it '#request_feedback' do
    email_subject = "Workshop Feedback for #{I18n.l(workshop.date_and_time, format: :email_title)}"

    FeedbackRequestMailer.request_feedback(workshop, member, feedback_request).deliver_now

    expect(email.subject).to eq(email_subject)
  end
end
