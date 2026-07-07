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

  describe '#event_organiser?' do
    let(:chapter) { Fabricate(:chapter) }
    let(:workshop) { Fabricate(:workshop_no_sponsor, chapter: chapter) }

    it 'returns true when user is admin' do
      admin = Fabricate(:member)
      admin.add_role(:admin)
      presenter = MemberPresenter.new(admin)

      expect(presenter.event_organiser?(workshop)).to be true
    end

    it 'returns true when user is direct organiser of the event' do
      member.add_role(:organiser, workshop)

      expect(member_presenter.event_organiser?(workshop)).to be true
    end

    it 'returns true when user is organiser of the event chapter' do
      organiser = Fabricate(:member)
      organiser.add_role(:organiser, chapter)
      presenter = MemberPresenter.new(organiser)

      expect(presenter.event_organiser?(workshop)).to be true
    end

    it 'returns false for a regular member' do
      regular = Fabricate(:member)
      presenter = MemberPresenter.new(regular)

      expect(presenter.event_organiser?(workshop)).to be false
    end

    it 'returns false for organiser of a different chapter' do
      other_chapter = Fabricate(:chapter)
      other_workshop = Fabricate(:workshop_no_sponsor, chapter: other_chapter)
      organiser = Fabricate(:member)
      organiser.add_role(:organiser, other_chapter)
      presenter = MemberPresenter.new(organiser)

      expect(presenter.event_organiser?(workshop)).to be false
    end

    it 'handles events without a singular chapter association (e.g. Meeting) without crashing' do
      meeting = Fabricate(:meeting)
      meeting_presenter = MeetingPresenter.new(meeting)
      admin = Fabricate(:member)
      admin.add_role(:admin)
      presenter = MemberPresenter.new(admin)

      expect(presenter.event_organiser?(meeting_presenter)).to be true
    end

    it 'memoizes private methods across calls' do
      member.add_role(:admin)

      expect(member).to receive(:has_role?).with(:admin).once.and_call_original
      # First call loads and caches
      member_presenter.event_organiser?(workshop)
      # Second call uses cache
      member_presenter.event_organiser?(workshop)
    end
  end
end
