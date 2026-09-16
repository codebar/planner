require 'rails_helper'

RSpec.describe 'Sitemap' do
  let!(:chapter) { Fabricate(:chapter) }
  let!(:workshop) { Fabricate(:workshop_no_sponsor, chapter:) }
  let!(:event) { Fabricate(:event) }
  let!(:meeting) { Fabricate(:meeting) }

  it 'serves the sitemap as XML' do
    get '/sitemap.xml'

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/xml')
  end

  it 'lists chapters, workshops, events, meetings and static pages' do
    get '/sitemap.xml'

    body = response.body
    expect(body).to include(root_url)
    expect(body).to include(chapter_url(chapter.slug))
    expect(body).to include(workshop_url(workshop))
    expect(body).to include(event_url(event))
    expect(body).to include(meeting_url(meeting))
    expect(body).to include(code_of_conduct_url)
    expect(body).to include(faq_url)
    expect(body).to include(privacy_policy_url)
  end

  it 'includes lastmod for records' do
    get '/sitemap.xml'

    expect(response.body).to include("<lastmod>#{workshop.reload.updated_at.utc.iso8601}</lastmod>")
    expect(response.headers['Cache-Control']).to include('public')
  end

  it 'includes new records once their section cache key changes' do
    with_fragment_caching do
      get '/sitemap.xml'
      expect(response.body).to include(workshop_url(workshop))

      new_workshop = Fabricate(:workshop_no_sponsor, chapter:)
      get '/sitemap.xml'

      expect(response.body).to include(workshop_url(new_workshop))
    end
  end

  it 'stops listing a deleted record once the section cache expires' do
    Fabricate(:workshop_no_sponsor, chapter:)
    workshop.update_columns(updated_at: 1.hour.ago)
    with_fragment_caching do
      get '/sitemap.xml'
      expect(response.body).to include(workshop_url(workshop))

      workshop.destroy
      travel 2.days do
        get '/sitemap.xml'
      end

      expect(response.body).not_to include(workshop_url(workshop))
    end
  end

  def with_fragment_caching
    old_cache = Rails.cache
    old_perform_caching = ActionController::Base.perform_caching
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    ActionController::Base.cache_store = Rails.cache
    ActionController::Base.perform_caching = true
    yield
  ensure
    Rails.cache = old_cache
    ActionController::Base.cache_store = old_cache
    ActionController::Base.perform_caching = old_perform_caching
  end
end
