require 'rails_helper'

RSpec.describe DashboardController do
  def assigns(symbol)
    controller.instance_variable_get("@#{symbol}")
  end

  describe 'GET #wall_of_fame' do
    render_views

    it 'paginates coaches at 20 per page with a second page available' do
      workshop = Fabricate(:workshop, date_and_time: Time.zone.now)
      21.times do |i|
        Fabricate(:attended_coach,
                  member: Fabricate(:member, name: "Coach#{i}", surname: 'Wall'),
                  workshop:)
      end

      get :wall_of_fame

      expect(assigns(:pagy).pages).to eq(2)
      expect(assigns(:coaches).size).to eq(20)
      expect(response.body).to include('page=2')

      get :wall_of_fame, params: { page: 2 }

      expect(assigns(:coaches).size).to eq(1)
      expect(assigns(:coaches).first.name).to start_with('Coach')
    end
  end

  describe 'GET #wall_of_fame caching' do
    render_views

    around do |example|
      original_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
      Rails.cache = original_cache
    end

    let!(:workshop) { Fabricate(:workshop, date_and_time: Time.zone.now) }

    before do
      Fabricate(:attended_coach,
                member: Fabricate(:member, name: 'Cached', surname: 'Coach'),
                workshop:)
    end

    it 'stores the rendered body for 24 hours under a date, year, page, and locale key' do
      expected_key = "coaches/wall_of_fame/v1/#{Time.zone.today}/#{Time.zone.now.year}/1/en"

      allow(Rails.cache).to receive(:fetch)
        .with(expected_key, expires_in: 24.hours)
        .and_call_original

      get :wall_of_fame

      expect(response.body).to include('Cached Coach')
      expect(response.body).to include('<!DOCTYPE html')
      expect(Rails.cache).to have_received(:fetch)
        .with(expected_key, expires_in: 24.hours)
      expect(Rails.cache.read(expected_key)).to be_present
    end

    it 'serves the cached body without re-rendering from the database' do
      get :wall_of_fame
      expect(response.body).to include('Cached Coach')

      WorkshopInvitation.where(member: Member.find_by(name: 'Cached')).destroy_all

      get :wall_of_fame
      expect(response.body).to include('Cached Coach')
    end

    it 'rotates the cache key with the year and page parameters' do
      get :wall_of_fame
      get :wall_of_fame, params: { year: 2024 }
      get :wall_of_fame, params: { page: 2 }

      base_key = "coaches/wall_of_fame/v1/#{Time.zone.today}"
      expect(Rails.cache.read("#{base_key}/#{Time.zone.now.year}/1/en")).to be_present
      expect(Rails.cache.read("#{base_key}/2024/1/en")).to be_present
      expect(Rails.cache.read("#{base_key}/#{Time.zone.now.year}/2/en")).to be_present
    end
  end
end
