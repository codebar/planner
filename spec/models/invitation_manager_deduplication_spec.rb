require 'rails_helper'

RSpec.describe InvitationManager do
  subject(:manager) { InvitationManager.new }

  let(:chapter) { Fabricate(:chapter) }
  let(:member_in_both_groups) { Fabricate(:member, accepted_toc_at: Time.zone.now) }

  describe '#chapter_students' do
    context 'when a member has multiple subscriptions to the same group type' do
      before do
        students_group1 = Fabricate(:group, name: 'Students', chapter: chapter)
        students_group2 = Fabricate(:group, name: 'Students', chapter: chapter)
        students_group1.members << member_in_both_groups
        students_group2.members << member_in_both_groups
      end

      it 'returns unique members' do
        result = manager.send(:chapter_students, chapter)

        expect(result.count).to eq(1)
        expect(result).to contain_exactly(member_in_both_groups)
      end
    end
  end

  describe '#chapter_coaches' do
    context 'when a member has multiple subscriptions to the same group type' do
      before do
        coaches_group1 = Fabricate(:group, name: 'Coaches', chapter: chapter)
        coaches_group2 = Fabricate(:group, name: 'Coaches', chapter: chapter)
        coaches_group1.members << member_in_both_groups
        coaches_group2.members << member_in_both_groups
      end

      it 'returns unique members' do
        result = manager.send(:chapter_coaches, chapter)

        expect(result.count).to eq(1)
        expect(result).to contain_exactly(member_in_both_groups)
      end
    end
  end

  describe 'sending invitations to members in both students and coaches groups' do
    let(:workshop) { Fabricate(:workshop, chapter: chapter) }
    let(:students_group) { Fabricate(:group, name: 'Students', chapter: chapter) }
    let(:coaches_group) { Fabricate(:group, name: 'Coaches', chapter: chapter) }

    before do
      students_group.members << member_in_both_groups
      coaches_group.members << member_in_both_groups
    end

    it 'creates one invitation per role when audience is everyone' do
      expect do
        manager.send_workshop_emails(workshop, 'everyone')
      end.to change(WorkshopInvitation, :count).by(2)

      # Verify the member has one invitation per role
      student_invitation = WorkshopInvitation.find_by(workshop: workshop, member: member_in_both_groups, role: 'Student')
      coach_invitation = WorkshopInvitation.find_by(workshop: workshop, member: member_in_both_groups, role: 'Coach')

      expect(student_invitation).to be_present
      expect(coach_invitation).to be_present
      expect(student_invitation.id).not_to eq(coach_invitation.id)
    end
  end
end
