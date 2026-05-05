RSpec.describe Group do
  subject(:group) { Fabricate.build(:group) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it do
      expect(subject).to validate_inclusion_of(:name)
        .in_array(%w[Coaches Students])
        .with_message('Invalid name for Group')
    end
  end

  describe '#eligible_members' do
    let(:group) { Fabricate(:group, name: 'Students') }

    it 'includes only members with accepted TOC who are not banned' do
      eligible_member = Fabricate(:member, groups: [group], accepted_toc_at: Time.zone.now)
      _ineligible_no_toc = Fabricate(:member, groups: [group], accepted_toc_at: nil)
      _ineligible_banned = Fabricate(:banned_member, groups: [group], accepted_toc_at: Time.zone.now)

      expect(group.eligible_members).to contain_exactly(eligible_member)
    end

    it 'returns empty relation when no eligible members' do
      Fabricate(:member, groups: [group], accepted_toc_at: nil)
      expect(group.eligible_members).to be_empty
    end
  end

  describe '.members_by_recent_rsvp' do
    let(:group) { Fabricate(:group, name: 'Students') }
    let(:chapter) { group.chapter }

    it 'orders members by most recent workshop RSVP' do
      old_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: 1.month.ago)
      new_workshop = Fabricate(:workshop, chapter: chapter, date_and_time: 1.week.ago)

      member_old = Fabricate(:member, groups: [group])
      member_new = Fabricate(:member, groups: [group])
      _member_no_rsvp = Fabricate(:member, groups: [group])

      Fabricate(:workshop_invitation, workshop: old_workshop, member: member_old, attending: true)
      Fabricate(:workshop_invitation, workshop: new_workshop, member: member_new, attending: true)

      results = Group.members_by_recent_rsvp(group).to_a

      expect(results.first).to eq(member_new)
      expect(results.last).to eq(_member_no_rsvp)
    end
  end
end
