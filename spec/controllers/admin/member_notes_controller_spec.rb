RSpec.describe Admin::MemberNotesController, type: :controller do
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

  describe 'PATCH #update' do
    let!(:member_note) { Fabricate(:member_note, member: member, author: admin, note: 'Original note') }

    it "Doesn't allow anonymous users to edit notes" do
      patch :update, params: { id: member_note.id, member_note: { note: 'Updated anonymously' } }
      expect(member_note.reload.note).to eq('Original note')
    end

    it "Doesn't allow regular users to edit notes" do
      login member

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by member' } }
      expect(member_note.reload.note).to eq('Original note')
    end

    it 'Allows admin to edit notes' do
      login admin

      patch :update, params: { id: member_note.id, member_note: { note: 'Updated by admin' } }
      expect(member_note.reload.note).to eq('Updated by admin')
    end

    it "Doesn't allow notes to be updated to be blank" do
      login admin

      patch :update, params: { id: member_note.id, member_note: { note: '' } }
      expect(member_note.reload.note).to eq('Original note')
    end
  end

  describe 'DELETE #destroy' do
    let!(:member_note) { Fabricate(:member_note, member: member, author: admin, note: 'Note') }

    it "Doesn't allow anonymous users to delete notes" do
      expect do
        delete :destroy, params: { id: member_note.id }
      end.not_to change { MemberNote.all.count }
    end

    it "Doesn't allow regular users to delete notes" do
      login member

      expect do
        delete :destroy, params: { id: member_note.id }
      end.not_to change { MemberNote.all.count }
    end

    it 'Allows note owner to delete notes' do
      login admin

      expect do
        delete :destroy, params: { id: member_note.id }
      end.to change { MemberNote.count }.by(-1)
    end
  end
end
