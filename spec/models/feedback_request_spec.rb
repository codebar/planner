RSpec.describe FeedbackRequest do
  subject { Fabricate(:feedback_request) }

  it { should respond_to(:member) }
  it { should respond_to(:workshop) }
  it { should respond_to(:token) }
  it { should respond_to(:submited) }

  context 'validations' do
    context 'presence' do
      it '#workshop should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, workshop: nil)

        expect(feedback_request).to_not be_valid
        expect(feedback_request).to have(1).error_on(:workshop)
      end

      it '#submitted should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, submited: nil)

        expect(feedback_request).to_not be_valid
        expect(feedback_request).to have(1).error_on(:submited)
      end
    end
  end

  context 'after create hook' do
    it 'sends request feedback email' do
      expect {
        Fabricate(:feedback_request)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Feedback')
    end
  end
end
