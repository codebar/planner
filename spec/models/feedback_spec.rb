require 'spec_helper'

describe Feedback do
  subject(:feedback) { Fabricate.build(:feedback) }

  let(:valid_feedback_token) { 'valid_feedback_token' }
  let(:invalid_feedback_token) { 'invalid_feedback_token' }
  
  it { should respond_to(:request) }
  it { should respond_to(:token) }
  it { should respond_to(:rating) }
  it { should respond_to(:suggestions) }
  it { should respond_to(:coach) }
  it { should respond_to(:tutorial)}

  context "validations" do
    context '#rating' do
      it 'should not be blank' do
        feedback = Fabricate.build(:feedback, rating: nil)

        feedback.should_not be_valid
        feedback.should have(3).error_on(:rating)
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
        feedback.should have(2).error_on(:rating)
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

  context '#create_token' do
    it 'is created when token is not blank' do
      Feedback.create_token(valid_feedback_token)

      Feedback.find_by_token(valid_feedback_token).should_not be_nil
    end

    it 'is not created when token is blank' do
      Feedback.create_token('')

      Feedback.find_by_token('').should be_nil
    end
  end

  context "#submit_feedback" do
    let (:valid_params) do
      {
        token: valid_feedback_token,
        rating: 4,
        coach: Fabricate(:coach),
        tutorial: Fabricate(:tutorial)
      }
    end

    let(:invalid_token_params) do
      { 
        token: invalid_feedback_token, 
        rating: 4,
        coach: Fabricate(:coach), 
        tutorial: Fabricate(:tutorial)
      }
    end

    let(:valid_token_invalid_params) do
      { 
        token: valid_feedback_token, 
        coach: Fabricate(:coach) 
      }
    end

    it 'is submited with valid token' do
      Feedback.create_token(valid_feedback_token)
      Feedback.submit_feedback(valid_params)

      Feedback.find_by(valid_params).should_not be_nil
    end

    it 'is not submited with invalid token' do
      Feedback.create_token(valid_feedback_token)
      Feedback.submit_feedback(invalid_token_params)

      Feedback.find_by(invalid_token_params).should be_nil
    end

    it 'is not submited with valid token but invalid params' do
      Feedback.create_token(valid_feedback_token)
      Feedback.submit_feedback(valid_token_invalid_params)

      Feedback.find_by(valid_token_invalid_params).should be_nil
    end    
  end
end
