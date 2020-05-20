require 'spec_helper'

RSpec.describe Ban, type: :model do
  context 'validates' do
    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_presence_of(:note) }
    it { is_expected.to validate_presence_of(:added_by) }
   end
  end
  context '#active?' do
    it 'is active in the future' do
      expect(Fabricate.build(:ban, expires_at: Time.zone.now + 1.minute)).to be_active
    end

    it 'is inactive in the past' do
      expect(Fabricate.build(:ban, expires_at: Time.zone.now - 1.minute)).to_not be_active
    end
  end
end
