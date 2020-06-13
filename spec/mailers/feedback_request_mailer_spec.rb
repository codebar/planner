require 'spec_helper'

RSpec.describe FeedbackRequestMailer, type: :mailer  do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:member) { Fabricate(:member) }
  let(:feedback_request) { Fabricate(:feedback_request, workshop: workshop, member: member) }

  context 'workshop' do
    let(:workshop) { Fabricate(:workshop, title: 'HTML & CSS') }

    it '#request_feedback' do
      email_subject = "Workshop Feedback for #{I18n.l(workshop.date_and_time, format: :email_title)}"

      FeedbackRequestMailer.request_feedback(workshop, member, feedback_request).deliver_now

      expect(email.subject).to eq(email_subject)
      expect(email.from).to eq(['meetings@codebar.io'])
    end
  end

  context 'virtual workshop' do
    let(:workshop) { Fabricate(:virtual_workshop) }

    it '#request_feedback' do
      email_subject = "Virtual Workshop Feedback for #{I18n.l(workshop.date_and_time, format: :email_title)}"

      FeedbackRequestMailer.request_feedback(workshop, member, feedback_request).deliver_now

      expect(email.subject).to eq(email_subject)
      expect(email.from).to eq(['meetings@codebar.io'])
      puts email.body
    end
  end
end
