require 'rails_helper'

RSpec.describe 'Event card fragments on listing pages' do
  # The card fragment is keyed on every record it renders. A sponsor, venue or
  # organiser change leaves the event row untouched, so a key on the event
  # alone kept the old card on every listing page until the event itself was
  # edited.
  let(:chapter) { Fabricate(:chapter, active: true) }
  let(:fragment_store) { ActiveSupport::Cache::MemoryStore.new }
  let!(:workshop) { Fabricate(:workshop, chapter:, date_and_time: 2.days.from_now) }

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

  # Scoped to the card: the chapter page also lists the sponsor by name in its
  # sponsors section, which would mask a stale card.
  def card
    Capybara.string(response.body).find("[data-test='event']", match: :first)
  end

  # Renders the page twice around a host rename: the second card must show the
  # new name while the workshop's own key did not move.
  shared_examples 'a listing that shows a renamed host' do
    it 'shows the renamed host in the card without the workshop row changing' do
      get path
      expect(card).to have_link(workshop.host.name)
      key_before = workshop.reload.cache_key_with_version

      workshop.host.update!(name: 'Renamed Host')

      get path
      expect(workshop.reload.cache_key_with_version).to eq(key_before)
      expect(card).to have_link('Renamed Host')
    end
  end

  describe 'the homepage' do
    let(:path) { '/' }

    include_examples 'a listing that shows a renamed host'
  end

  describe '/events/upcoming' do
    let(:path) { '/events/upcoming' }

    include_examples 'a listing that shows a renamed host'
  end

  describe 'the chapter page' do
    let(:path) { "/#{chapter.slug}" }

    include_examples 'a listing that shows a renamed host'
  end

  describe 'the member dashboard' do
    let(:path) { '/dashboard' }

    before do
      member = Fabricate(:member)
      Fabricate(:subscription, member:, group: Fabricate(:group, chapter:))
      Fabricate(:auth_service, member:, provider: 'github', uid: 'card-fragment-uid')
      mock_auth_hash(provider: 'github', uid: 'card-fragment-uid', email: member.email)
      post '/auth/github/callback'
    end

    include_examples 'a listing that shows a renamed host'
  end
end
