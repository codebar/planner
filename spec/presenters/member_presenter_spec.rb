RSpec.describe MemberPresenter do
  let(:member) { Fabricate(:member, skill_list: 'java, ruby') }
  let(:member_presenter) { MemberPresenter.new(member) }

  it '#organiser?' do
    expect(member).to receive(:has_role?).with(:organiser, :any)

    member_presenter.organiser?
  end

  it '#subscribed_to_newsletter?' do
    expect(member).to receive(:opt_in_newsletter_at)

    member_presenter.subscribed_to_newsletter?
  end

  describe '#pairing_details_array' do
    it 'returns student pairing information' do
      expect(member_presenter.pairing_details_array('Student', 'Tutorial', 'Note'))
        .to eq([member_presenter.newbie?, member.full_name, 'Student', 'Tutorial', 'Note', 'N/A'])
    end

    it 'returns coach pairing information' do
      expect(member_presenter.pairing_details_array('Coach', nil, 'A note'))
        .to eq([member_presenter.newbie?, member.full_name, 'Coach', 'N/A', 'A note', 'java, ruby'])
    end
  end

  describe '#attending?' do
    let(:event) { Fabricate(:event) }

    it 'returns true when member is attending event' do
      Fabricate(:invitation, member: member, event: event, attending: true)
      expect(member_presenter.attending?(event)).to be true
    end

    it 'returns false when member is not attending' do
      expect(member_presenter.attending?(event)).to be false
    end
  end
end
