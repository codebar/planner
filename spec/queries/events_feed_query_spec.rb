require 'rails_helper'

RSpec.describe EventsFeedQuery do
  let(:request) do
    {
      base_url: 'http://example.test',
      path: '/events',
      params: {},
      cookie: {}
    }
  end

  describe '#call' do
    context 'when fetching past events' do
      it 'returns an empty hash and nil pagy when no events exist' do
        result = described_class.new(upcoming: false, page: 1, request:).call

        expect(result).to eq([{}, nil])
      end

      it 'returns events from each type in reverse date order and excludes inactive chapters' do
        now = Time.zone.now
        meeting = Fabricate(:meeting, date_and_time: now - 1.day)
        workshop = Fabricate(:workshop, date_and_time: now - 2.days, ends_at: now - 2.days + 2.hours)
        event = Fabricate(:event, date_and_time: now - 3.days)
        Fabricate(:event, date_and_time: now + 1.day)
        Fabricate(:workshop, chapter: Fabricate(:chapter, active: false),
                             date_and_time: now - 4.days,
                             ends_at: now - 4.days + 2.hours)

        events, pagy = described_class.new(upcoming: false, page: 1, request:).call
        listed_events =
          events
          .values
          .flat_map { |day_events| day_events }
          .map { |listed_event| [listed_event.class_string, listed_event.id] }

        expect(listed_events).to eq([['meeting', meeting.id], ['workshop', workshop.id], ['event', event.id]])
        expect(events.keys).to eq([meeting.date, workshop.date, event.date])
        expect(pagy.count).to eq(3)
      end

      it 'paginates in reverse chronological order and builds links for the past path' do
        venue = Fabricate(:sponsor)
        meetings = Array.new(21) do |index|
          date_and_time = Time.zone.now - (index + 1).days
          Fabricate(:meeting, venue:, date_and_time:, ends_at: date_and_time + 2.hours)
        end
        Fabricate(:meeting, venue:, date_and_time: Time.zone.now + 1.day)
        past_request = request.merge(path: '/events/past')

        events, pagy = described_class.new(upcoming: false, page: 1, request: past_request).call
        next_page_events, next_page_pagy = described_class.new(upcoming: false, page: 2, request: past_request).call

        expected_first_page = meetings.sort_by(&:date_and_time).reverse.first(20)
        expect(events.values.flat_map { |day_events| day_events }.map(&:id)).to eq(expected_first_page.map(&:id))
        expect(pagy.count).to eq(21)
        expect(pagy.page_url(:next)).to eq('/events/past?page=2')
        expect(next_page_events.values.flat_map { |day_events| day_events }.map(&:id))
          .to eq([meetings.min_by(&:date_and_time).id])
        expect(next_page_pagy.count).to eq(21)
      end
    end

    context 'when fetching upcoming events' do
      it 'returns an empty hash and nil pagy when no events exist' do
        result = described_class.new(upcoming: true, page: 1, request:).call

        expect(result).to eq([{}, nil])
      end

      it 'returns events from each type in date order and excludes inactive chapters' do
        now = Time.zone.now
        meeting = Fabricate(:meeting, date_and_time: now + 1.day, ends_at: now + 1.day + 2.hours)
        workshop = Fabricate(:workshop, date_and_time: now + 2.days, ends_at: now + 2.days + 2.hours)
        event = Fabricate(:event, date_and_time: now + 3.days)

        events, pagy = described_class.new(upcoming: true, page: 1, request:).call
        listed_events =
          events
          .values
          .flat_map { |day_events| day_events }
          .map { |listed_event| [listed_event.class_string, listed_event.id] }

        expect(listed_events).to eq([['meeting', meeting.id], ['workshop', workshop.id], ['event', event.id]])
        expect(events.keys).to eq([meeting.date, workshop.date, event.date])
        expect(pagy.count).to eq(3)
      end

      it 'builds pagination links for the upcoming events path' do
        21.times do |index|
          date_and_time = Time.zone.now + (index + 1).days
          Fabricate(:meeting, date_and_time:, ends_at: date_and_time + 2.hours)
        end
        upcoming_request = request.merge(path: '/events/upcoming')

        events, pagy = described_class.new(upcoming: true, page: 1, request: upcoming_request).call

        expect(events.values.flat_map { |day_events| day_events }.size).to eq(20)
        expect(pagy.count).to eq(21)
        expect(pagy.page_url(:next)).to eq('/events/upcoming?page=2')
      end
    end
  end

  describe '#load_events' do
    let(:query) { described_class.new(upcoming: true, page: 1, request:) }
    let(:chapter) { Fabricate(:chapter) }
    let(:host_sponsor) { Fabricate(:sponsor, name: 'Zulu GmbH') }
    let(:extra_sponsor) { Fabricate(:sponsor, name: 'Alpha AG') }

    def rows_for(workshops)
      workshops.map { |workshop| { 'event_type' => 'Workshop', 'id' => workshop.id } }
    end

    it 'loads the host sponsor as workshop_host for every workshop' do
      workshops = Fabricate.times(6, :workshop_no_sponsor, chapter:)
      workshops.each do |workshop|
        Fabricate(:workshop_sponsor, workshop:, sponsor: host_sponsor, host: true)
        Fabricate(:workshop_sponsor, workshop:, sponsor: extra_sponsor, host: false)
      end

      loaded = query.send(:load_events, rows_for(workshops))

      expect(loaded.map { |event| event.workshop_host&.sponsor&.id }).to all(eq(host_sponsor.id))
    end

    it 'lists all sponsors of a workshop' do
      workshop = Fabricate(:workshop_no_sponsor, chapter:)
      Fabricate(:workshop_sponsor, workshop:, sponsor: host_sponsor, host: true)
      Fabricate(:workshop_sponsor, workshop:, sponsor: extra_sponsor, host: false)

      loaded = query.send(:load_events, rows_for([workshop]))

      expect(loaded.first.sponsors).to contain_exactly(host_sponsor, extra_sponsor)
    end

    it 'renders sponsors and organisers in name order' do
      workshop = Fabricate(:workshop_no_sponsor, chapter:)
      Fabricate(:workshop_sponsor, workshop:, sponsor: host_sponsor, host: true)
      Fabricate(:workshop_sponsor, workshop:, sponsor: extra_sponsor, host: false)
      anton = Fabricate(:member, name: 'Anton')
      zora = Fabricate(:member, name: 'Zora')
      anton.add_role :organiser, workshop
      zora.add_role :organiser, workshop

      loaded = query.send(:load_events, rows_for([workshop]))
      presenter = EventPresenter.decorate(loaded.first)

      expect(presenter.sponsors.map(&:name)).to eq(['Alpha AG', 'Zulu GmbH'])
      expect(presenter.organisers.map(&:name)).to eq(%w[Anton Zora])
    end

    it 'sorts organisers with blank names without raising' do
      workshop = Fabricate(:workshop_no_sponsor, chapter:)
      anton = Fabricate(:member, name: 'Anton')
      anton.update_column(:name, nil)
      anton.add_role :organiser, workshop
      Fabricate(:member, name: 'Zora').add_role :organiser, workshop

      loaded = query.send(:load_events, rows_for([workshop]))
      presenter = EventPresenter.decorate(loaded.first)

      expect(presenter.organisers.map(&:name)).to eq([nil, 'Zora'])
    end
  end
end
