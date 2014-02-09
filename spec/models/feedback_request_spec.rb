require 'spec_helper'

describe FeedbackRequest do
  subject { Fabricate(:feedback_request) }

  it { should respond_to(:member) }
  it { should respond_to(:sessions) }
  it { should respond_to(:token) }
  it { should respond_to(:submited) }

  context "validations" do
    context 'presence' do
      it '#member should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, member: nil)

        feedback_request.should_not be_valid
        feedback_request.should have(1).error_on(:member)
      end

      it '#session should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, sessions: nil)

        feedback_request.should_not be_valid
        feedback_request.should have(1).error_on(:sessions)
      end

      it '#token should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, token: nil)

        feedback_request.should_not be_valid
        feedback_request.should have(1).error_on(:token)
      end

      it '#submited should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, submited: nil)

        feedback_request.should_not be_valid
        feedback_request.should have(1).error_on(:submited)
      end
    end
  end

  context "after create hook" do
    it "#email" do
      feedback_request = Fabricate.build(:feedback_request)
      feedback_request.stub(:email)
      feedback_request.save
      feedback_request.should have_received(:email)
    end

    it "sends request feedback email" do
      FeedbackRequestMailer.stub(:request_feedback)
      Fabricate(:feedback_request)
      FeedbackRequestMailer.should have_received(:request_feedback)
    end
  end
 
end
