require 'spec_helper'

describe Feedback do
  subject(:feedback) { Fabricate.build(:feedback) }

  let(:valid_feedback_token) { 'valid_feedback_token' }
  let(:invalid_feedback_token) { 'invalid_feedback_token' }

  it { should respond_to(:request) }
  it { should respond_to(:rating) }
  it { should respond_to(:suggestions) }
  it { should respond_to(:coach) }
  it { should respond_to(:tutorial)}

  context "validations" do
    context '#rating' do
      it 'should not be blank' do
        feedback = Fabricate.build(:feedback, rating: nil)

        feedback.should_not be_valid
        feedback.should have(1).error_on(:rating)
      end

      it 'should accept numbers from 1 to 5' do
        (1..5).each do |rating|
          feedback = Fabricate.build(:feedback, rating: rating)

          feedback.should be_valid
        end
      end

      it 'should be invalid with number higher than 5' do
        feedback = Fabricate.build(:feedback, rating: 6)

        feedback.should_not be_valid
        feedback.should have(1).error_on(:rating)
      end

      it 'should be invalid with number lower than 1' do
        feedback = Fabricate.build(:feedback, rating: 0)

        feedback.should_not be_valid
        feedback.should have(1).error_on(:rating)
      end

      it 'should be numerical' do
        feedback = Fabricate.build(:feedback, rating: 'alpha')

        feedback.should_not be_valid
        feedback.should have(1).error_on(:rating)
      end
    end

    context "#coach" do

      it "accepts memeber with 'coach' role" do
        feedback = Fabricate.build(:feedback, coach: Fabricate(:coach))

        feedback.should be_valid
      end

      it "is invalid with memeber with 'student' role" do
        feedback = Fabricate.build(:feedback, coach: Fabricate(:student))

        feedback.should_not be_valid
        feedback.should have(1).error_on(:coach)
      end

      it "should display correct error message when member with 'student' role given" do
        feedback = Fabricate.build(:feedback, coach: Fabricate(:student))

        feedback.valid?

        feedback.errors.messages[:coach].should include "Coach member doesn't have 'coach' role."
      end
    end
  end

  context "#submit_feedback" do
    let(:feedback_request) { Fabricate(:feedback_request) }

    let (:params) do
      { rating: 4, coach: Fabricate(:coach), tutorial: Fabricate(:tutorial) }
    end

    context 'with valid token' do
      it 'is submited valid params' do
        expect {
          Feedback.submit_feedback(params, feedback_request.token)
        }.to change { Feedback.count }.by(1)
      end

      it 'is not submited invalid params' do
        expect {
          Feedback.submit_feedback(params.except(:rating), feedback_request.token)
        }.to_not change { Feedback.count }
      end
    end

    it 'is not submited with invalid token' do
      expect {
        Feedback.submit_feedback(params, 'invalid_token')
      }.to_not change { Feedback.count }
    end
  end
end
