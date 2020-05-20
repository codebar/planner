require 'spec_helper'

RSpec.describe Ban, type: :model do
  context 'validates' do
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_presence_of(:note) }
    it { is_expected.to validate_presence_of(:added_by) }

    context '#expires_at' do
      it 'valid in the future' do
        ban = Fabricate.build(:ban, expires_at: Time.zone.now + 1.minute)
        ban.valid?
        expect(ban.errors[:expires_at]).to be_empty
      end

      it 'invalid in the past' do
        ban = Fabricate.build(:ban, expires_at: Time.zone.now - 1.minute)
        ban.valid?
        expect(ban.errors[:expires_at]).to include('must be in the future')
      end
    end
  end

  context 'scope' do
    context 'active' do
      it 'includes bans expiring in the future' do
        ban = Fabricate(:ban, expires_at: Time.zone.now + 1.minute)
        expect(Ban.active).to include(ban)
      end

      it 'excludes expired bans' do
        ban = Fabricate(:ban, expires_at: Time.zone.now + 1.minute)
        travel 5.minutes do
          expect(Ban.active).to_not include(ban)
        end
      end
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
