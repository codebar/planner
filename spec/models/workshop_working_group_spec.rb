require 'spec_helper'

RSpec.describe WorkshopWorkingGroup do
  let(:workshop) { Fabricate(:workshop) }

  describe 'validations' do
    it 'requires a positive integer position' do
      group = described_class.new(workshop:, position: 0)
      expect(group).not_to be_valid
      expect(group.errors[:position]).to be_present
    end

    it 'is valid with a workshop and positive position' do
      group = described_class.new(workshop:, position: 1)
      expect(group).to be_valid
    end
  end

  describe '.ordered' do
    it 'orders by position ascending then id ascending' do
      second = described_class.create!(workshop:, position: 2)
      first = described_class.create!(workshop:, position: 1)

      expect(workshop.workshop_working_groups.ordered).to eq([first, second])
    end
  end
end
