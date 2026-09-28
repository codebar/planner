require 'rails_helper'

RSpec.describe 'Chapter show page caching' do
  let(:chapter) { Fabricate(:chapter, active: true) }
  let(:fragment_store) { ActiveSupport::Cache::MemoryStore.new }

  around do |example|
    old_perform_caching = ActionController::Base.perform_caching
    old_cache_store = ActionController::Base.cache_store

    ActionController::Base.perform_caching = true
    ActionController::Base.cache_store = fragment_store

    example.run
  ensure
    ActionController::Base.perform_caching = old_perform_caching
    ActionController::Base.cache_store = old_cache_store
  end

  before do
    organiser = Fabricate(:member)
    organiser.add_role(:organiser, chapter)
    past_workshop = Fabricate(:workshop, chapter:, date_and_time: 2.days.ago)
    Fabricate(:workshop_sponsor, workshop: past_workshop)
    Fabricate(:workshop, chapter:, date_and_time: Time.current + 3.days)
  end

  it 'caches the static sections so a repeat visit issues fewer queries' do
    first_visit_queries = count_queries { get "/#{chapter.slug}" }
    repeat_visit_queries = count_queries { get "/#{chapter.slug}" }

    expect(response).to have_http_status(:ok)
    expect(repeat_visit_queries).to be < first_visit_queries
  end

  it 'stores fragments for the cached sections' do
    get "/#{chapter.slug}"

    fragment_keys = fragment_store.instance_variable_get(:@data).keys
    expect(fragment_keys.grep(/chapter_sponsors/)).to be_present
    expect(fragment_keys.grep(/chapter_organisers/)).to be_present
  end

  it 'serves a 304 to anonymous conditional requests through the full stack' do
    get "/#{chapter.slug}"
    etag = response.headers['etag']

    get "/#{chapter.slug}", headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:not_modified)
  end

  it 'serves a fresh 200 after a sponsor changes so repeat anonymous visits are not stale' do
    get "/#{chapter.slug}"
    etag = response.headers['etag']

    sponsor = Fabricate(:sponsor)
    Fabricate(:workshop_sponsor, sponsor:, workshop: chapter.workshops.upcoming.first)

    get "/#{chapter.slug}", headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:ok)
  end

  it 'serves a fresh 200 after an organiser changes on an upcoming workshop' do
    get "/#{chapter.slug}"
    etag = response.headers['etag']

    organiser = Fabricate(:member)
    organiser.add_role(:organiser, chapter.workshops.upcoming.first)

    get "/#{chapter.slug}", headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:ok)
  end

  it 'serves a fresh 200 after the past event changes' do
    get "/#{chapter.slug}"
    etag = response.headers['etag']

    past_workshop = chapter.workshops.past.first
    organiser = Fabricate(:member)
    organiser.add_role(:organiser, past_workshop)

    get "/#{chapter.slug}", headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:ok)
  end

  it 'serves a fresh 200 after an upcoming workshop crosses into the past (time-only change)' do
    Fabricate(:workshop_no_sponsor, chapter:, date_and_time: 30.minutes.from_now)
    get "/#{chapter.slug}"
    etag = response.headers['etag']

    travel 2.hours do
      get "/#{chapter.slug}", headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:ok)
    end
  end

  it 'never serves a 304 to logged-in members so the per-user subscription section stays fresh' do
    Fabricate(:group, chapter:)
    get "/#{chapter.slug}"
    etag = response.headers['etag']

    member = Fabricate(:member)
    Fabricate(:auth_service, member:, provider: 'github', uid: 'chapter-caching-uid')
    mock_auth_hash(provider: 'github', uid: 'chapter-caching-uid', email: member.email)
    post '/auth/github/callback'

    get "/#{chapter.slug}", headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:ok)
    # The per-user subscriptions section replaces the anonymous sign-up button.
    expect(response.body).to include('Subscribe to')
  end

  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      queries += 1 unless payload[:name] == 'SCHEMA' || payload[:sql] =~ /\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
