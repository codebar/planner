RSpec.describe DashboardQuery do
  describe '.upcoming_events' do
    it 'returns an empty hash when there are no upcoming events' do
      expect(described_class.upcoming_events).to eq({})
    end

    it 'includes upcoming events and meetings alongside workshops' do
      workshop = Fabricate(:workshop)
      event = Fabricate(:event)
      meeting = Fabricate(:meeting)

      result = described_class.upcoming_events

      expect(result.values.flatten).to include(workshop, event, meeting)
    end

    it 'limits to exactly 3 distinct dates' do
      Fabricate(:workshop, date_and_time: 1.day.from_now)
      Fabricate(:workshop, date_and_time: 2.days.from_now)
      Fabricate(:workshop, date_and_time: 3.days.from_now)
      Fabricate(:workshop, date_and_time: 4.days.from_now)

      result = described_class.upcoming_events

      expect(result.keys.length).to eq(3)
    end

    it 'excludes past workshops' do
      Fabricate(:workshop, date_and_time: 1.month.ago)

      expect(described_class.upcoming_events).to eq({})
    end
  end

  describe '.upcoming_events_for_user' do
    it 'returns events for the member chapters and accepted workshops' do
      chapter = Fabricate(:chapter)
      member = Fabricate(:member, groups: [Fabricate(:students, chapter: chapter)])
      workshop = Fabricate(:workshop, chapter: chapter)
      Fabricate(:attending_workshop_invitation, member: member, workshop: workshop)

      result = described_class.upcoming_events_for_user(member)

      expect(result.values.flatten).to include(workshop)
    end

    it 'returns an empty hash when the member has no upcoming events' do
      member = Fabricate(:member)

      expect(described_class.upcoming_events_for_user(member)).to eq({})
    end
  end

  describe '.total_upcoming_events_count' do
    it 'returns 0 when there are no upcoming events' do
      expect(described_class.total_upcoming_events_count).to eq(0)
    end

    it 'counts upcoming workshops, events, and meetings' do
      Fabricate(:workshop)
      Fabricate(:event)
      Fabricate(:meeting)

      expect(described_class.total_upcoming_events_count).to eq(3)
    end

    it 'does not count past events' do
      Fabricate(:past_workshop)

      expect(described_class.total_upcoming_events_count).to eq(0)
    end
  end
end
