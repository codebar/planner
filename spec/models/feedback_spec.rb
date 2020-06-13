require 'spec_helper'

RSpec.describe Feedback, type: :model do
  subject(:feedback) { Fabricate.build(:feedback) }

  context 'validations' do
    context '#rating' do
      it { is_expected.to validate_presence_of(:rating) }
      it { is_expected.to validate_inclusion_of(:rating).in_range(1..5).with_message(/can't be blank/) }
    end

    it { is_expected.to validate_presence_of(:tutorial) }
  end

  context '#submit_feedback' do
    let(:feedback_request) { Fabricate(:feedback_request) }

    let(:params) do
      { rating: 4, coach: Fabricate(:coach), tutorial: Fabricate(:tutorial) }
    end

    context 'with valid token' do
      it 'is  submitted valid params' do
        expect do
          Feedback.submit_feedback(params, feedback_request.token)
        end.to change { Feedback.count }.by(1)
      end

      it 'is not submitted invalid params' do
        expect do
          Feedback.submit_feedback(params.except(:rating), feedback_request.token)
        end.to_not change { Feedback.count }
      end
    end

    it 'is not submitted with invalid token' do
      expect do
        Feedback.submit_feedback(params, 'invalid_token')
      end.to_not change { Feedback.count }
    end
  end
end
