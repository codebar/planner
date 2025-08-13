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
    it "Doesn't allow anonymous users to update notes" do
      patch :update, params: { id: member_note.id, member_note: { note: 'Updated note' } }
      expect(response).to redirect_to(root_path)
    end

    it "Doesn't allow regular users to update notes" do
      login member
      patch :update, params: { id: member_note.id, member_note: { note: 'Updated note' } }
      expect(response).to redirect_to(root_path)
    end

    it 'Allows chapter organisers to update notes' do
      login admin
      patch :update, params: { id: member_note.id, member_note: { note: 'Updated note' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Note updated successfully.')
    end

    it "Doesn't allow blank notes to be updated" do
      login admin
      patch :update, params: { id: member_note.id, member_note: { note: ' ' } }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq("Note can't be blank")
    end
  end

  describe 'DELETE #destroy' do
    it "Doesn't allow anonymous users to delete notes" do
      delete :destroy, params: { id: member_note.id }
      expect(response).to redirect_to(root_path)
    end

    it "Doesn't allow regular users to delete notes" do
      login member
      delete :destroy, params: { id: member_note.id }
      expect(response).to redirect_to(root_path)
    end

    it 'Allows chapter organisers to delete notes' do
      login admin
      delete :destroy, params: { id: member_note.id }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Note deleted successfully.')
    end
  end
end
