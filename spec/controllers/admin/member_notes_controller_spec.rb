require 'spec_helper'

describe Admin::MemberNotesController, type: :controller do
  let(:member) { Fabricate(:member) }
  let(:admin) { Fabricate(:chapter_organiser) }
  let!(:member_note) { Fabricate(:member_note) }

  describe 'POST #create' do
    it "Doesn't allow anonymous users to create notes" do
      expect do
        post :create, params: { member_note: { note: member_note.note, member_id: member.id } }
      end.not_to change { MemberNote.all.count }
    end

    it "Doesn't allow regular users to create notes" do
      login member

      expect do
        post :create, params: { member_note: { note: member_note.note, member_id: member.id } }
      end.not_to change { MemberNote.all.count }
    end

    it 'Allows chapter organisers to create notes' do
      login admin
      request.env['HTTP_REFERER'] = '/admin/member/3'

      expect do
        post :create, params: { member_note: { note: member_note.note, member_id: member.id } }
      end.to change { MemberNote.all.count }.by 1
    end

    it "Doesn't allow blank notes to be created" do
      expect do
        post :create, params: { member_note: { note: ' ', member_id: member.id } }
      end.not_to change { MemberNote.all.count }
    end
  end
end
