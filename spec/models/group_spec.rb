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
end
