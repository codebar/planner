require 'rails_helper'

RSpec.describe 'Homepage chapters sidebar fragment' do
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
    Fabricate(:chapter, name: 'Newcastle', slug: 'newcastle')
    Fabricate(:chapter, name: 'London', slug: 'london')
  end

  def count_sidebar_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      queries += 1 if payload[:sql].match?(/"chapters"\."active"/)
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  it 'stores the sidebar as a fragment' do
    get '/'

    fragment_keys = fragment_store.instance_variable_get(:@data).keys
    expect(fragment_keys.grep(/chapters-sidebar/)).to be_present
  end

  it 'runs no sidebar query on a warm fragment' do
    get '/'

    warm_queries = count_sidebar_queries { get '/' }

    expect(response).to have_http_status(:ok)
    expect(warm_queries).to be_zero
  end

  it 'drops a chapter deactivated by a direct database update within the TTL' do
    get '/'
    expect(response.body).to include('Newcastle')

    Chapter.where(slug: 'newcastle').update_all(active: false)

    get '/'
    expect(response.body).to include('Newcastle')

    travel_to(11.minutes.from_now) do
      get '/'

      expect(response.body).to include('London')
      expect(response.body).not_to include('Newcastle')
    end
  end
end
