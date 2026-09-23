require 'rails_helper'

RSpec.describe 'Event card render query cost' do
  # Regression guard for the cache-miss render path of EventCardComponent:
  # organisers/venue lookups are eager-loaded with the relation, so the SQL
  # cost of a listing page must not grow per rendered card.

  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do
      queries += 1
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  # Absolute per-render ceilings for the two event-listing actions.
  #
  # Measured baseline (2026-09-23), request-spec environment, warm render of 4
  # cards per page: 9 queries for GET /events/past and 9 for GET /events/upcoming.
  # That count is the floor: the 4 MAX(updated_at) fresh_when etag lookups, the
  # UNION pagination COUNT, and one eager_load query each for Workshops,
  # Meetings, and Events. A production render adds ~20 Solid Cache fragment
  # reads (one per event card) that do not appear here, so test-env and
  # production counts are not directly comparable.
  #
  # Ceiling = baseline rounded up to the next multiple of 5, so exactly one
  # query of slack is tolerated above the measured floor of 9. A growth-only
  # guard cannot catch a constant excess added above the floor; this pins it.
  # If this spec fails, investigate the regression -- do not raise the ceiling
  # to make it pass. A constant excess of 2 or more fails the pin; a +1 excess
  # is inside the slack.
  let(:pinned_ceiling) { 10 }

  it 'does not add per-card queries on /events/upcoming as cards grow' do
    chapter = Fabricate(:chapter, active: true)
    organiser = Fabricate(:member)
    first_workshop = Fabricate(:workshop, chapter:)
    organiser.add_role(:organiser, first_workshop)

    get '/events/upcoming'
    one_card = count_queries { get '/events/upcoming' }

    3.times do
      workshop = Fabricate(:workshop, chapter:)
      organiser.add_role(:organiser, workshop)
    end

    four_cards = count_queries { get '/events/upcoming' }

    expect(four_cards).to be <= one_card + 8
  end

  it 'stays at the pinned query floor on /events/past' do
    chapter = Fabricate(:chapter, active: true)
    organiser = Fabricate(:member)
    first_workshop = Fabricate(:past_workshop, chapter:)
    organiser.add_role(:organiser, first_workshop)

    3.times { Fabricate(:past_workshop, chapter:) }

    # Warm-up request: schema/fixture one-time queries do not count against
    # the ceiling.
    get '/events/past'

    actual = count_queries { get '/events/past' }

    # Guard against a vacuous pass: an empty result set short-circuits the
    # render path and lowers the query count, so pin the exercised path too.
    expect(response).to have_http_status(:ok)
    expect(response.body.scan(chapter.slug).count).to be >= 4

    expect(actual).to(be <= pinned_ceiling,
                      "GET /events/past issued #{actual} queries, ceiling is #{pinned_ceiling} " \
                      '(measured baseline: 9). Compare against the baseline comment if this fails.')
  end

  it 'stays at the pinned query floor on /events/upcoming' do
    chapter = Fabricate(:chapter, active: true)
    organiser = Fabricate(:member)
    first_workshop = Fabricate(:workshop, chapter:)
    organiser.add_role(:organiser, first_workshop)

    3.times { Fabricate(:workshop, chapter:) }

    get '/events/upcoming'

    actual = count_queries { get '/events/upcoming' }

    # Guard against a vacuous pass: an empty result set short-circuits the
    # render path and lowers the query count, so pin the exercised path too.
    expect(response).to have_http_status(:ok)
    expect(response.body.scan(chapter.slug).count).to be >= 4

    expect(actual).to(be <= pinned_ceiling,
                      "GET /events/upcoming issued #{actual} queries, ceiling is #{pinned_ceiling} " \
                      '(measured baseline: 9). Compare against the baseline comment if this fails.')
  end

  it 'does not add per-card queries for hosted workshops on /events/upcoming' do
    chapter = Fabricate(:chapter, active: true)
    host_sponsor = Fabricate(:sponsor)
    first_workshop = Fabricate(:workshop_no_sponsor, chapter:)
    Fabricate(:workshop_sponsor, workshop: first_workshop, sponsor: host_sponsor, host: true)

    get '/events/upcoming'
    one_card = count_queries { get '/events/upcoming' }

    3.times do
      workshop = Fabricate(:workshop_no_sponsor, chapter:)
      Fabricate(:workshop_sponsor, workshop:, sponsor: host_sponsor, host: true)
    end

    four_cards = count_queries { get '/events/upcoming' }

    expect(four_cards).to eq(one_card)
  end

  it 'does not add per-card queries on the chapter page as cards grow' do
    chapter = Fabricate(:chapter, active: true)
    organiser = Fabricate(:member)
    first_workshop = Fabricate(:workshop, chapter:)
    organiser.add_role(:organiser, first_workshop)

    get "/#{chapter.slug}"
    one_card = count_queries { get "/#{chapter.slug}" }

    3.times do
      workshop = Fabricate(:workshop, chapter:)
      organiser.add_role(:organiser, workshop)
    end

    four_cards = count_queries { get "/#{chapter.slug}" }

    expect(four_cards).to be <= one_card + 8
  end
end
