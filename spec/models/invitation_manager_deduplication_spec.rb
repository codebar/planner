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

    it 'sends one invitation per role when audience is everyone' do
      expect(WorkshopInvitation).to receive(:find_or_create_by)
        .with(workshop: workshop, member: member_in_both_groups, role: 'Student')
        .and_call_original
        .once

      expect(WorkshopInvitation).to receive(:find_or_create_by)
        .with(workshop: workshop, member: member_in_both_groups, role: 'Coach')
        .and_call_original
        .once

      manager.send_workshop_emails(workshop, 'everyone')
    end
  end
end
