require 'rails_helper'

RSpec.describe ChapterContactAudience do
  describe '.options' do
    it 'returns translated audience labels in configured order' do
      expect(described_class.options).to eq([
                                              ['All chapter members', 'all_members'],
                                              ['Chapter organisers', 'chapter_organisers'],
                                              ['Leadership team', 'leadership_team'],
                                              ['Custom list', 'custom_list'],
                                              ['Active in the last month', 'active_last_month'],
                                              ['Inactive for the last month', 'inactive_last_month'],
                                              ['Event RSVP status', 'event_rsvp']
                                            ])
    end
  end

  describe '.activity_period_options' do
    it 'uses localized singular and plural labels' do
      expect(described_class.activity_period_options).to eq([
                                                              ['1 month', '1'], ['3 months', '3'], ['6 months', '6'], ['12 months', '12']
                                                            ])
    end
  end

  describe '.rsvp_status_options' do
    it 'returns the supported translated RSVP statuses' do
      expect(described_class.rsvp_status_options).to eq([
                                                          ['Attending', 'attending'], ['Declined', 'declined'], ['No response', 'unanswered']
                                                        ])
    end
  end

  describe '.valid_activity_months?' do
    it 'accepts only configured periods for activity audiences' do
      described_class::ACTIVITY_MONTHS.each do |months|
        expect(described_class.valid_activity_months?('active_last_month', months)).to be(true)
      end

      expect(described_class.valid_activity_months?('active_last_month', '9')).to be(false)
      expect(described_class.valid_activity_months?('inactive_last_month', nil)).to be(false)
    end

    it 'does not require an activity period for other audiences' do
      expect(described_class.valid_activity_months?('all_members', nil)).to be(true)
    end
  end

  describe '.error' do
    it 'returns audience-specific errors and a general fallback' do
      expect(described_class.error('event_rsvp'))
        .to eq('No current chapter members match that event RSVP status.')
      expect(described_class.error('unknown')).to eq('There are no current chapter subscribers to email.')
    end
  end
end
