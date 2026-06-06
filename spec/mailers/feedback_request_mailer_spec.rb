RSpec.describe FeedbackRequestMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:member) { Fabricate(:member) }
  let(:feedback_request) { Fabricate(:feedback_request, workshop: workshop, member: member) }

  context 'when the member has an invalid email' do
    let(:workshop) { Fabricate(:workshop) }
    let(:bad_member) { Fabricate(:member) }
    let(:bad_feedback_request) { Fabricate(:feedback_request, workshop: workshop, member: bad_member) }

    before { allow(bad_member).to receive(:email).and_return('invalid-email') }

    it '#request_feedback skips delivery without crashing' do
      expect {
        FeedbackRequestMailer.request_feedback(workshop, bad_member, bad_feedback_request).deliver_now
      }.not_to raise_error
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

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
    end
  end
end
