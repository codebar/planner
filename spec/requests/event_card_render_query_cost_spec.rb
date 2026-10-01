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

  it 'does not add per-card queries on /events/past as mixed card types grow' do
    chapter = Fabricate(:chapter, active: true)
    organiser = Fabricate(:member)
    first_workshop = Fabricate(:past_workshop, chapter:)
    organiser.add_role(:organiser, first_workshop)
    first_meeting = Fabricate(:meeting, date_and_time: 2.weeks.ago)
    organiser.add_role(:organiser, first_meeting)
    first_event = Fabricate(:event_with_sponsorship, date_and_time: 2.weeks.ago)
    organiser.add_role(:organiser, first_event)

    get '/events/past'
    three_cards = count_queries { get '/events/past' }

    3.times do
      workshop = Fabricate(:past_workshop, chapter:)
      organiser.add_role(:organiser, workshop)
      meeting = Fabricate(:meeting, date_and_time: 2.weeks.ago)
      organiser.add_role(:organiser, meeting)
      event = Fabricate(:event_with_sponsorship, date_and_time: 2.weeks.ago)
      organiser.add_role(:organiser, event)
    end

    twelve_cards = count_queries { get '/events/past' }

    expect(twelve_cards).to eq(three_cards)
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
