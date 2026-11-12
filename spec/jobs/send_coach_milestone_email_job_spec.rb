require 'rails_helper'

RSpec.describe SendCoachMilestoneEmailJob do
  describe '#perform' do
    it 'delegates to the coach milestone email service' do
      allow(CoachMilestoneEmailService).to receive(:send_milestone_emails)

      described_class.new.perform

      expect(CoachMilestoneEmailService).to have_received(:send_milestone_emails)
    end
  end
end
