require 'rails_helper'

RSpec.describe InvitationLogEntry do
  describe 'associations' do
    it { is_expected.to belong_to(:invitation_log) }
    it { is_expected.to belong_to(:member) }
    it { is_expected.to belong_to(:invitation).optional }
  end

  describe 'enums' do
    it 'defines status enum with string values' do
      expect(InvitationLogEntry.statuses).to eq({
                                                  'success' => 'success',
                                                  'failed' => 'failed',
                                                  'skipped' => 'skipped'
                                                })
    end
  end
end
