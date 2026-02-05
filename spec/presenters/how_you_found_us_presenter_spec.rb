RSpec.describe HowYouFoundUsPresenter do
  def add_member(group, how)
    member = Fabricate(:member, how_you_found_us: how)
    Fabricate(:subscription, member: member, group: group)
    member
  end

  def add_member_without_how(group)
    member = Fabricate(:member, how_you_found_us: nil)
    Fabricate(:subscription, member: member, group: group)
    member
  end

  let(:chapter) { Fabricate(:chapter_without_organisers) }
  let(:group) { Fabricate(:group, chapter: chapter) }
  let(:presenter) { HowYouFoundUsPresenter.new(chapter) }

  describe '#by_percentage' do
    it 'returns integer percentages for all enum values in enum order using largest remainder rounding' do
      add_member(group, :from_a_friend)
      add_member(group, :search_engine)
      add_member(group, :search_engine)
      add_member(group, :social_media)
      add_member(group, :social_media)
      add_member(group, :social_media)

      expect(presenter.by_percentage).to eq(
        {
          'from_a_friend' => 17,
          'search_engine' => 33,
          'social_media' => 50,
          'codebar_host_or_partner' => 0,
          'other' => 0
        }
      )
      expect(presenter.by_percentage.values.sum).to eq(100)
    end

    it 'returns all enum values with zeros when there is no data' do
      expect(presenter.by_percentage).to eq(
        {
          'from_a_friend' => 0,
          'search_engine' => 0,
          'social_media' => 0,
          'codebar_host_or_partner' => 0,
          'other' => 0
        }
      )
    end
  end

  describe '#total_responses' do
    it 'sums the counts' do
      add_member(group, :from_a_friend)
      add_member(group, :search_engine)

      expect(presenter.total_responses).to eq(2)
    end
  end

  describe '#data_present?' do
    it 'returns true when there are responses' do
      add_member(group, :from_a_friend)

      expect(presenter.data_present?).to eq(true)
    end

    it 'returns false when there are no responses' do
      expect(presenter.data_present?).to eq(false)
    end
  end
end
