require 'rails_helper'

RSpec.describe 'Event listing caching' do
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

    # The listing etag is the MAX(updated_at) across workshops, meetings,
    # events and members, digested at second precision; each touch moves one
    # table's updated_at past the current maximum so the etag must rotate.
    it 'serves a fresh 200 when any of the four tables feeding the etag changes' do
      [past_workshop, meeting, event, organiser].each_with_index do |record, index|
        get '/events/past'
        etag = response.headers['etag']

        record.touch(time: (index + 1).seconds.from_now)

        get '/events/past', headers: { 'HTTP_IF_NONE_MATCH' => etag }

        expect(response).to have_http_status(:ok)
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
