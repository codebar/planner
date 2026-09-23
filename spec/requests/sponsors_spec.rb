# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sponsors' do
  let!(:sponsor) { Fabricate.create(:sponsor, name: 'Acme Corp') }

  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
    Rails.cache = original_cache
  end

  it 'renders the sponsors page within the application layout' do
    get '/sponsors'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('<!DOCTYPE html>')
    expect(response.body).to match(/rel="stylesheet"/)
  end

  it 'renders the sponsors content' do
    get '/sponsors'

    expect(response.body).to include('Acme Corp')
  end

  it 'serves the cached body when no sponsor has been updated' do
    get '/sponsors'

    # update_columns bypasses callbacks, so updated_at (and the cache key) stays unchanged
    sponsor.update_columns(name: 'Renamed Corp')

    get '/sponsors'

    expect(response.body).to include('Acme Corp')
    expect(response.body).not_to include('Renamed Corp')
  end

  it 're-renders when a sponsor is updated' do
    get '/sponsors'

    sponsor.update!(name: 'Renamed Corp')

    get '/sponsors'

    expect(response.body).to include('Renamed Corp')
  end
end
