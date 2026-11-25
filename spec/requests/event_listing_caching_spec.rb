require 'rails_helper'

RSpec.describe 'Event listing caching' do
  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') { queries += 1 }
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  context 'when the listings have content' do
    let(:chapter) { Fabricate(:chapter, active: true) }
    let(:organiser) { Fabricate(:member) }
    let!(:past_workshop) { Fabricate(:past_workshop, chapter:) }
    let!(:meeting) { Fabricate(:meeting, date_and_time: 2.weeks.ago) }
    let!(:event) { Fabricate(:event, date_and_time: 2.weeks.ago) }

    before do
      organiser.add_role(:organiser, past_workshop)
      organiser.add_role(:organiser, meeting)
      organiser.add_role(:organiser, event)
    end

    it 'serves a 304 to anonymous conditional requests for /events/past through the full stack' do
      get '/events/past'
      etag = response.headers['etag']

      get '/events/past', headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:not_modified)
    end

    it 'serves a 304 to anonymous conditional requests for /events/upcoming through the full stack' do
      Fabricate(:workshop, chapter:)

      get '/events/upcoming'
      etag = response.headers['etag']

      get '/events/upcoming', headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:not_modified)
    end

    it 'renders the listing cards on a cache miss' do
      get '/events/past'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-test="event"')
    end

    # The listing etag is the MAX(updated_at) across EventsController::LISTING_TABLES,
    # digested at second precision; each touch moves one table's updated_at
    # past the current maximum so the etag must rotate.
    it 'serves a fresh 200 when any of the event or member tables feeding the etag changes' do
      [past_workshop, meeting, event, organiser].each_with_index do |record, index|
        get '/events/past'
        etag = response.headers['etag']

        record.touch(time: (index + 1).seconds.from_now)

        get '/events/past', headers: { 'HTTP_IF_NONE_MATCH' => etag }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'when a card on /events/upcoming renders records outside the event tables' do
    let(:chapter) { Fabricate(:chapter, active: true) }
    let!(:workshop) { Fabricate(:workshop, chapter:) }
    let!(:event) { Fabricate(:event) }
    let!(:sponsor) { Fabricate(:sponsor) }
    let!(:extra_sponsor) { Fabricate(:sponsor) }

    before { Fabricate(:sponsorship, event:, sponsor:) }

    # The chapter, host, venue and sponsors are rendered by the card but leave
    # the event rows untouched when they change. Each change is stamped one
    # second past the current maximum so the second-precision etag has to move.
    def expect_fresh_response_after
      get '/events/upcoming'
      etag = response.headers['etag']

      yield

      get '/events/upcoming', headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:ok)
    end

    it 'keeps serving a 304 while none of those records change' do
      get '/events/upcoming'
      etag = response.headers['etag']

      get '/events/upcoming', headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:not_modified)
    end

    it 'answers the conditional request with a single query' do
      get '/events/upcoming'
      etag = response.headers['etag']

      queries = count_queries { get '/events/upcoming', headers: { 'HTTP_IF_NONE_MATCH' => etag } }

      expect(response).to have_http_status(:not_modified)
      expect(queries).to eq(1)
    end

    it 'serves a fresh 200 after a sponsor rename' do
      expect_fresh_response_after do
        sponsor.update!(name: 'Renamed Sponsor', updated_at: 1.second.from_now)
      end
    end

    it 'serves a fresh 200 after a host rename' do
      expect_fresh_response_after do
        workshop.host.update!(name: 'Renamed Host', updated_at: 1.second.from_now)
      end
    end

    it 'serves a fresh 200 after a venue rename' do
      expect_fresh_response_after do
        event.venue.update!(name: 'Renamed Venue', updated_at: 1.second.from_now)
      end
    end

    it 'serves a fresh 200 after a chapter rename' do
      expect_fresh_response_after do
        chapter.update!(name: 'Renamed Chapter', updated_at: 1.second.from_now)
      end
    end

    it 'serves a fresh 200 after a new event sponsorship' do
      expect_fresh_response_after do
        Fabricate(:sponsorship, event:, sponsor: extra_sponsor, updated_at: 1.second.from_now)
      end
    end

    it 'serves a fresh 200 after a new workshop sponsor' do
      expect_fresh_response_after do
        Fabricate(:workshop_sponsor, workshop:, sponsor: extra_sponsor, host: false, updated_at: 1.second.from_now)
      end
    end
  end

  context 'when the database is empty' do
    it 'renders the past listing and keeps its etag stable while nothing has happened' do
      get '/events/past'
      etag = response.headers['etag']

      expect(response).to have_http_status(:ok)

      get '/events/past', headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:not_modified)
    end
  end
end
