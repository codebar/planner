require 'spec_helper'

describe MemberNote do
  context 'Mandatory attributes' do
    it 'Requires a note' do
      note = Fabricate.build(:member_note, note: nil)

      expect(note).not_to be_valid
      expect(note).to have(1).error_on(:note)

      note.note = ''
      expect(note).not_to be_valid
      expect(note).to have(1).error_on(:note)
    end

    it 'Requires a member' do
      note = Fabricate.build(:member_note, member: nil)
      expect(note).not_to be_valid
      expect(note).to have(1).error_on(:member)
    end

    it 'Requires an author' do
      note = Fabricate.build(:member_note, author: nil)
      expect(note).not_to be_valid
      expect(note).to have(1).error_on(:author)
    end
  end
end
