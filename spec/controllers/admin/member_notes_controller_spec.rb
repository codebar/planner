require 'rails_helper'

RSpec.describe Admin::MemberNotesController do
  let(:member) { Fabricate(:member) }
  let(:chapter) { Fabricate(:chapter) }
  let(:organiser) { Fabricate(:member).tap { |m| m.add_role(:organiser, chapter) } }
  let(:other_chapter_organiser) { Fabricate(:chapter_organiser) }
  let(:admin) { Fabricate(:member).tap { |m| m.add_role(:admin) } }
  # Notes are created by admins/organisers, and the admin area bounces anyone
  # without an admin or organiser role, so author tests need an organising
  # author whose chapter is not the member's.
  let(:author) { Fabricate(:chapter_organiser) }
  let!(:member_note) { Fabricate(:member_note) }

  before do
    Fabricate(:students, chapter:, members: [member])
  end

  describe 'POST #create' do
    it "Doesn't allow anonymous users to create notes" do
      expect do
        post :create, params: { member_note: { note: member_note.note, member_id: member.id } }
      end.not_to(change { MemberNote.all.count })
    end

    it "Doesn't allow regular users to create notes" do
      login member

      expect do
        post :create, params: { member_note: { note: member_note.note, member_id: member.id } }
      end.not_to(change { MemberNote.all.count })
    end

    it 'Allows chapter organisers to create notes' do
      login organiser
      request.env['HTTP_REFERER'] = '/admin/member/3'

      expect do
        post :create, params: { member_note: { note: member_note.note, member_id: member.id } }
      end.to change { MemberNote.all.count }.by 1
    end

    it "Doesn't allow blank notes to be created" do
      expect do
        post :create, params: { member_note: { note: ' ', member_id: member.id } }
      end.not_to(change { MemberNote.all.count })
    end

    it 'records member_note.created' do
      login organiser
      request.env['HTTP_REFERER'] = '/admin/member/3'

      post :create, params: { member_note: { member_id: member.id, note: 'context' } }

      expect(PublicActivity::Activity.exists?(key: 'member_note.created', recipient: member)).to be(true)
    end
  end

  describe 'PATCH #update' do
    let!(:member_note) { Fabricate(:member_note, member:, author:, note: 'Original note') }

    it "Doesn't allow anonymous users to edit notes" do
      patch :update, params: { id: member_note.id, member_note: { note: 'Updated anonymously' } }
      expect(member_note.reload.note).to eq('Original note')
    end

    it "Doesn't allow regular users to edit notes" do
      login member

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by member' } }
      expect(member_note.reload.note).to eq('Original note')
    end

    it "Doesn't allow organisers from other chapters to edit notes" do
      login other_chapter_organiser

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by other organiser' } }
      expect(member_note.reload.note).to eq('Original note')
    end

    it 'Allows admins to edit notes' do
      login admin

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by admin' } }
      expect(member_note.reload.note).to eq('Updated by admin')
    end

    it 'Allows organisers of the member\'s chapter to edit notes' do
      login organiser

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by organiser' } }
      expect(member_note.reload.note).to eq('Updated by organiser')
    end

    it 'Allows the note author to edit notes' do
      login author

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by author' } }
      expect(member_note.reload.note).to eq('Updated by author')
    end

    it "Doesn't allow notes to be updated to be blank" do
      login admin

      patch :update, params: { id: member_note.id, member_note: { note: '' } }
      expect(member_note.reload.note).to eq('Original note')
    end

    it "Doesn't allow member_id to be changed on update" do
      other_member = Fabricate(:member)
      login organiser

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by organiser', member_id: other_member.id } }
      expect(member_note.reload.member).to eq(member)
      expect(member_note.reload.note).to eq('Updated by organiser')
    end
  end

  describe 'DELETE #destroy' do
    let!(:member_note) { Fabricate(:member_note, member:, author:, note: 'Note') }

    it "Doesn't allow anonymous users to delete notes" do
      expect do
        delete :destroy, params: { id: member_note.id }
      end.not_to(change { MemberNote.all.count })
    end

    it "Doesn't allow regular users to delete notes" do
      login member

      expect do
        delete :destroy, params: { id: member_note.id }
      end.not_to(change { MemberNote.all.count })
    end

    it "Doesn't allow organisers from other chapters to delete notes" do
      login other_chapter_organiser

      expect do
        delete :destroy, params: { id: member_note.id }
      end.not_to(change { MemberNote.all.count })
    end

    it 'Allows admins to delete notes' do
      login admin

      expect do
        delete :destroy, params: { id: member_note.id }
      end.to change(MemberNote, :count).by(-1)
    end

    it 'Allows organisers of the member\'s chapter to delete notes' do
      login organiser

      expect do
        delete :destroy, params: { id: member_note.id }
      end.to change(MemberNote, :count).by(-1)
    end

    it 'Allows the note author to delete notes' do
      login author

      expect do
        delete :destroy, params: { id: member_note.id }
      end.to change(MemberNote, :count).by(-1)
    end
  end
end
