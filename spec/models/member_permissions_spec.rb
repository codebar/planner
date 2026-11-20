require 'rails_helper'

RSpec.describe Member do
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

  describe 'manages_chapters?' do
    it 'returns true if the member is an admin' do
      member.add_role(:admin)

      expect(member.manages_chapters?).to be true
    end

    it 'returns true if the member is a chapter organiser' do
      member.add_role(:organiser, chapter)

      expect(member.manages_chapters?).to be true
    end

    it 'returns true if the member is a global organiser' do
      member.add_role(:organiser)

      expect(member.manages_chapters?).to be true
    end

    it 'returns true if the member only organises a workshop' do
      member.add_role(:organiser, Fabricate(:workshop, chapter:))

      expect(member.manages_chapters?).to be true
    end

    it 'returns false if the member is not an organiser or an admin' do
      expect(member.manages_chapters?).to be false
    end
  end

  describe 'contactable_chapters' do
    it 'returns every chapter for an admin' do
      other_chapter = Fabricate(:chapter)
      member.add_role(:admin)

      expect(member.contactable_chapters).to include(chapter, other_chapter)
    end

    it 'returns every chapter for a global organiser' do
      other_chapter = Fabricate(:chapter)
      member.add_role(:organiser)

      expect(member.contactable_chapters).to include(chapter, other_chapter)
    end

    it 'returns the chapters the member organises' do
      member.add_role(:organiser, chapter)

      expect(member.contactable_chapters).to contain_exactly(chapter)
    end

    it 'returns the chapters of workshops the member organises' do
      member.add_role(:organiser, Fabricate(:workshop, chapter:))

      expect(member.contactable_chapters).to contain_exactly(chapter)
    end

    it 'returns the chapters of events the member organises' do
      member.add_role(:organiser, Fabricate(:event, chapters: [chapter]))

      expect(member.contactable_chapters).to contain_exactly(chapter)
    end

    it 'returns the chapters of meetings the member organises' do
      member.add_role(:organiser, Fabricate(:meeting, chapters: [chapter]))

      expect(member.contactable_chapters).to contain_exactly(chapter)
    end

    it 'returns no chapters for a member without an organiser role' do
      expect(member.contactable_chapters).to be_empty
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
