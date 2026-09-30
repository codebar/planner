require 'rails_helper'

RSpec.describe 'Workshop show page caching' do
  let(:workshop) { Fabricate(:workshop, description: '<p>Hello <b>codebar</b></p>') }
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
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      queries += 1 unless payload[:name] == 'SCHEMA' || payload[:sql] =~ /\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  it 'caches the static sections so a repeat visit issues fewer queries' do
    first_visit_queries = count_queries { get workshop_path(workshop) }
    repeat_visit_queries = count_queries { get workshop_path(workshop) }

    expect(response).to have_http_status(:ok)
    expect(repeat_visit_queries).to be < first_visit_queries
  end

  it 'stores fragments for the cached sections' do
    get workshop_path(workshop)

    fragment_keys = fragment_store.instance_variable_get(:@data).keys
    expect(fragment_keys.grep(%r{\Aviews/}).count).to be >= 3
  end

  it 'renders a hostile stored description through the sanitizer' do
    workshop = Fabricate(:workshop, description: '<p>Hello <script>alert(1)</script><b>codebar</b></p>')

    get workshop_path(workshop)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('<p>Hello alert(1)<b>codebar</b></p>')
    expect(response.body).not_to include('<script>alert(1)')
    expect(workshop.reload.description).to include('<script>')
  end

  it 'serves a 304 to anonymous conditional requests through the full stack' do
    get workshop_path(workshop)
    etag = response.headers['etag']

    get workshop_path(workshop), headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:not_modified)
  end

  it 'serves a fresh 200 after the host sponsor changes so repeat anonymous visits are not stale' do
    get workshop_path(workshop)
    etag = response.headers['etag']

    workshop.host.update!(name: "#{workshop.host.name} updated")

    get workshop_path(workshop), headers: { 'HTTP_IF_NONE_MATCH' => etag }

    expect(response).to have_http_status(:ok)
  end

  context 'when the workshop is virtual' do
    let(:workshop) { Fabricate(:virtual_workshop_sponsored) }

    it 'renders the virtual show page with virtual content and stores its fragments' do
      get workshop_path(workshop)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Virtual workshop for')

      fragment_keys = fragment_store.instance_variable_get(:@data).keys
      expect(fragment_keys.grep(/virtual_workshop_sponsors/)).to be_present
      expect(fragment_keys.grep(/virtual_workshop_organisers/)).to be_present
    end

    it 'serves a 304 to anonymous conditional requests through the full stack' do
      get workshop_path(workshop)
      etag = response.headers['etag']

      get workshop_path(workshop), headers: { 'HTTP_IF_NONE_MATCH' => etag }

      expect(response).to have_http_status(:not_modified)
    end
  end
end
