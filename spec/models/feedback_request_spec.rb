require 'spec_helper'

describe FeedbackRequest do
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
    it '#email' do
      feedback_request = Fabricate.build(:feedback_request)
      allow(feedback_request).to receive(:email)
      allow(feedback_request).to receive(:member_id).and_return(:member_id)
      feedback_request.save
      expect(feedback_request).to have_received(:email)
    end

    it 'sends request feedback email' do
      allow(FeedbackRequestMailer).to receive(:request_feedback) { double('feedback_request_mailer').as_null_object }
      Fabricate(:feedback_request)
      expect(FeedbackRequestMailer).to have_received(:request_feedback)
    end
  end

end
