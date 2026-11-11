require 'rails_helper'

RSpec.describe DashboardQuery do
  def count_queries(&block)
    queries = 0
    callback = lambda do |_name, _start, _finish, _id, payload|
      next if payload[:name] == 'SCHEMA' || payload[:cached]
      next if payload[:sql].nil? || payload[:sql].match?(/\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/)

      queries += 1
    end
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &block)
    queries
  end

  def read_card_attributes
    described_class.upcoming_events.values.flatten.each do |event|
      read_chapter(event)
      read_venue(event)
      event.sponsors.each(&:name) if event.respond_to?(:sponsors)
      event.organisers.each(&:name)
      event.host if event.is_a?(Workshop)
    end
  end

  def read_chapter(event)
    event.chapter&.name if event.respond_to?(:chapter)
  end

  def read_venue(event)
    event.venue&.name if event.respond_to?(:venue)
  end

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

    it 'loads each workshop host when workshops have multiple sponsors and organisers' do
      chapter = Fabricate(:chapter)
      additional_sponsor = Fabricate(:sponsor)
      host = Fabricate(:sponsor)
      organisers = Fabricate.times(2, :member)
      workshops = Fabricate.times(16, :workshop_no_sponsor, chapter:)

      workshops.each do |workshop|
        Fabricate(:workshop_sponsor, workshop:, sponsor: additional_sponsor)
        Fabricate(:workshop_sponsor, workshop:, sponsor: host, host: true)
        organisers.each { |organiser| organiser.add_role(:organiser, workshop) }
      end

      result = described_class.upcoming_events

      expect(result.values.flatten.select { |event| event.is_a?(Workshop) }.map(&:host))
        .to all(eq(host))
    end

    it 'does not add per-card queries as the number of workshops grows' do
      chapter = Fabricate(:chapter)
      host = Fabricate(:sponsor)
      additional_sponsor = Fabricate(:sponsor)
      organiser = Fabricate(:member)

      build_workshops = lambda do |count|
        count.times do
          workshop = Fabricate(:workshop_no_sponsor, chapter:)
          Fabricate(:workshop_sponsor, workshop:, sponsor: additional_sponsor)
          Fabricate(:workshop_sponsor, workshop:, sponsor: host, host: true)
          organiser.add_role(:organiser, workshop)
        end
      end

      build_workshops.call(1)
      read_card_attributes
      one_card = count_queries { read_card_attributes }

      build_workshops.call(3)
      four_cards = count_queries { read_card_attributes }

      expect(one_card).to be_positive
      expect(four_cards).to eq(one_card)
    end

    it 'resolves host to nil when the workshop only has non-host sponsors' do
      workshop = Fabricate(:workshop_no_sponsor)
      Fabricate(:workshop_sponsor, workshop:, sponsor: Fabricate(:sponsor), host: false)

      loaded = described_class.upcoming_events.values.flatten.find { |event| event == workshop }

      expect(loaded.host).to be_nil
    end

    it 'includes a workshop with no sponsors and resolves its host to nil' do
      workshop = Fabricate(:workshop_no_sponsor)

      loaded = described_class.upcoming_events.values.flatten.find { |event| event == workshop }

      expect(loaded).to eq(workshop)
      expect(loaded.host).to be_nil
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
    def create_invited_workshops(member:, count:, host:, extra_sponsor:)
      count.times do
        workshop = Fabricate(:workshop_no_sponsor)
        Fabricate(:workshop_sponsor, workshop:, sponsor: extra_sponsor)
        Fabricate(:workshop_sponsor, workshop:, sponsor: host, host: true)
        Fabricate(:attending_workshop_invitation, member:, workshop:)
      end
    end

    def create_chapter_workshops(chapter:, count:, host:, extra_sponsor:)
      count.times do
        workshop = Fabricate(:workshop_no_sponsor, chapter:)
        Fabricate(:workshop_sponsor, workshop:, sponsor: extra_sponsor)
        Fabricate(:workshop_sponsor, workshop:, sponsor: host, host: true)
      end
    end

    def load_user_events_and_count_host_queries(member:, host:)
      result = nil
      queries = count_queries do
        result = described_class.upcoming_events_for_user(member)
        workshops = result.values.flatten.select { |event| event.is_a?(Workshop) }
        expect(workshops.map(&:host)).to all(eq(host))
      end

      [result, queries]
    end

    it 'returns events for the member chapters and accepted workshops' do
      chapter = Fabricate(:chapter)
      member = Fabricate(:member, groups: [Fabricate(:students, chapter:)])
      workshop = Fabricate(:workshop, chapter:)
      Fabricate(:attending_workshop_invitation, member:, workshop:)

      result = described_class.upcoming_events_for_user(member)

      expect(result.values.flatten).to include(workshop)
    end

    it 'preloads workshop hosts for chapter workshops without growing query count' do
      chapter = Fabricate(:chapter)
      member = Fabricate(:member, groups: [Fabricate(:students, chapter:)])
      host = Fabricate(:sponsor)
      extra_sponsor = Fabricate(:sponsor)

      create_chapter_workshops(chapter:, count: 1, host:, extra_sponsor:)
      result_one = described_class.upcoming_events_for_user(member)
      one_query_count = count_queries { described_class.upcoming_events_for_user(member) }

      create_chapter_workshops(chapter:, count: 3, host:, extra_sponsor:)
      result_four = nil
      four_query_count = count_queries { result_four = described_class.upcoming_events_for_user(member) }

      expect(result_four.values.flatten.count { |event| event.is_a?(Workshop) }).to eq(4)
      expect(result_four.values.flatten.select { |event| event.is_a?(Workshop) }.map(&:host)).to all(eq(host))
      expect(four_query_count).to be <= one_query_count + 2
      expect(result_one.values.flatten.select { |event| event.is_a?(Workshop) }.map(&:host)).to all(eq(host))
    end

    it 'preloads workshop hosts for accepted invitations without growing query count with workshop count' do
      member = Fabricate(:member)
      host = Fabricate(:sponsor)
      extra_sponsor = Fabricate(:sponsor)
      expect(member.chapters).to be_empty

      create_invited_workshops(member:, count: 1, host:, extra_sponsor:)
      result_one, one_workshop_queries = load_user_events_and_count_host_queries(member:, host:)
      expect(result_one.values.flatten.count { |event| event.is_a?(Workshop) }).to eq(1)
      expect(one_workshop_queries).to be_positive

      create_invited_workshops(member:, count: 3, host:, extra_sponsor:)
      result_four, four_workshop_queries = load_user_events_and_count_host_queries(member:, host:)
      expect(result_four.values.flatten.count { |event| event.is_a?(Workshop) }).to eq(4)
      expect(four_workshop_queries).to be_positive
      expect(four_workshop_queries).to be <= one_workshop_queries + 2
    end

    it 'resolves host to nil for accepted workshops with only non-host sponsors' do
      member = Fabricate(:member)
      workshop = Fabricate(:workshop_no_sponsor)
      Fabricate(:workshop_sponsor, workshop:, sponsor: Fabricate(:sponsor), host: false)
      Fabricate(:attending_workshop_invitation, member:, workshop:)

      result = described_class.upcoming_events_for_user(member)
      loaded = result.values.flatten.find { |event| event == workshop }

      expect(loaded).to eq(workshop)
      expect(loaded.host).to be_nil
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
