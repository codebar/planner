require 'rails_helper'

RSpec.describe Admin::MemberNotesController do
  let(:member) { Fabricate(:member) }
  let(:admin) { Fabricate(:chapter_organiser) }
  let!(:member_note) { Fabricate(:member_note) }

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
      login admin
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
      member = Fabricate(:member)
      login admin
      request.env['HTTP_REFERER'] = '/admin/member/3'

      post :create, params: { member_note: { member_id: member.id, note: 'context' } }

      expect(PublicActivity::Activity.exists?(key: 'member_note.created', recipient: member)).to be(true)
    end
  end
end
