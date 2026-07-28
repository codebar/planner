RSpec.describe FeedbackRequest do
  subject { Fabricate(:feedback_request) }

  it { is_expected.to respond_to(:member) }
  it { is_expected.to respond_to(:workshop) }
  it { is_expected.to respond_to(:token) }
  it { is_expected.to respond_to(:submited) }

  context 'validations' do
    context 'presence' do
      it '#workshop should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, workshop: nil)

        expect(feedback_request).not_to be_valid
        expect(feedback_request).to have(1).error_on(:workshop)
      end

      it '#submitted should not be blank' do
        feedback_request = Fabricate.build(:feedback_request, submited: nil)

        expect(feedback_request).not_to be_valid
        expect(feedback_request).to have(1).error_on(:submited)
      end
    end
  end
end
