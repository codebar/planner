require 'rails_helper'

RSpec.describe 'Past events page fragment' do
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

  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') { queries += 1 }
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  before do
    Fabricate(:event, date_and_time: 2.weeks.ago, name: 'Ancient workshop')
    Fabricate(:event, date_and_time: 3.weeks.ago, name: 'Older workshop')
  end

  it 'stores the rendered page as a single fragment' do
    get '/events/past'

    fragment_keys = fragment_store.instance_variable_get(:@data).keys
    expect(fragment_keys.grep(/events_past_page/)).to be_present
  end

  it 'serves repeat visits from the fragment without the fetch pipeline' do
    first_visit_queries = count_queries { get '/events/past' }
    repeat_visit_queries = count_queries { get '/events/past' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Ancient workshop')
    expect(repeat_visit_queries).to be < first_visit_queries
  end

  it 'clamps invalid page params onto the page 1 fragment' do
    get '/events/past', params: { page: 0 }
    clamped_keys = fragment_store.instance_variable_get(:@data).keys

    get '/events/past'

    fragment_keys = fragment_store.instance_variable_get(:@data).keys
    expect(fragment_keys).to eq(clamped_keys)
  end

  it 'does not persist fragments for pages beyond the last page' do
    get '/events/past', params: { page: 999_999 }

    fragment_keys = fragment_store.instance_variable_get(:@data).keys
    expect(fragment_keys.grep(/events_past_page/)).to be_empty
  end

  it 'serves fresh content once a tracked table row changes' do
    get '/events/past'
    stale_body = response.body

    Fabricate(:event, date_and_time: 4.weeks.ago, name: 'Brand new past event')

    get '/events/past'

    expect(response.body).not_to eq(stale_body)
    expect(response.body).to include('Brand new past event')
  end

  it 'expires the fragment so a deleted event self-heals within the horizon' do
    get '/events/past'
    deleted = Event.find_by(name: 'Ancient workshop')
    deleted.destroy

    travel_to(31.minutes.from_now) do
      get '/events/past'

      expect(response.body).not_to include('Ancient workshop')
    end
  end
end
