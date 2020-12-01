require 'spec_helper'

RSpec.describe Permissions, type: :model do
  subject(:member) { Fabricate(:member) }

  let(:chapter) { Fabricate(:chapter) }

  describe 'organiser?' do
    it 'returns true when the member is a chapter organiser' do
      member.add_role(:organiser, chapter)

      expect(member.organiser?).to be true
    end
  end

  describe 'organised_chapters' do
    it 'returns the chapters that the member has organiser access on' do
      member.add_role(:organiser, chapter)
      expect(member.organised_chapters).to eq([chapter])
    end
  end

  describe 'monthlies_organiser' do
    it 'returns true if the member is a meeting organiser' do
      member.add_role(:organiser, Fabricate(:meeting))

      expect(member.monthlies_organiser?).to be true
    end
  end

  describe 'admin_or_organiser?' do
    it 'returns true if the member is an admin' do
      member.add_role(:admin)

      expect(member.admin_or_organiser?).to be true
    end

    it 'returns true if the member is an organiser' do
      member.add_role(:organiser, chapter)

      expect(member.admin_or_organiser?).to be true
    end

    it 'returns false if the member is not an organiser or an admin' do
      expect(member.admin_or_organiser?).to be false
    end
  end
end
