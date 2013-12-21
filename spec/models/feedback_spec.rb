require 'spec_helper'

describe Feedback do
  subject(:feedback) { Fabricate.build(:feedback) }

  it { should respond_to(:request) }
  it { should respond_to(:suggestions) }
  it { should respond_to(:coach) }
  it { should respond_to(:tutorial)}

  context "validations" do
    it "#coach accepts memeber with 'coach' role" do
      feedback = Fabricate.build(:feedback, coach: Fabricate(:coach))

      feedback.should be_valid
    end

    it "#coach is invalid with memeber with 'student' role" do
      feedback = Fabricate.build(:feedback, coach: Fabricate(:student))

      feedback.should_not be_valid
      feedback.should have(1).error_on(:coach)
    end

    it "#coach should display correct error message when member with 'student' role given" do
      feedback = Fabricate.build(:feedback, coach: Fabricate(:student))

      feedback.valid?

      feedback.errors.messages[:coach].should include "Coach member doesn't have 'coach' role."
    end
  end
end
