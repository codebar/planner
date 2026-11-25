require 'rails_helper'

RSpec.describe EventCardComponent do
  include Rails.application.routes.url_helpers

  let(:chapter) { Fabricate(:chapter, active: true) }

  context 'with a workshop' do
    let(:workshop) { Fabricate(:workshop, chapter:) }
    let(:presenter) { WorkshopPresenter.new(workshop) }

    it 'renders the workshop card' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_css("[data-test='event']")
      expect(page).to have_link(presenter.to_s)
      expect(page).to have_text(presenter.date)
    end

    it 'does not render user-specific badges without a user' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_no_text('Attending')
      expect(page).to have_no_text('Manage')
    end

    it 'renders chapter badge linking to the chapter path' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_link(chapter.name, href: chapter_path(chapter.slug))
    end
  end

  context 'with a meeting' do
    let(:meeting) { Fabricate(:meeting) }
    let(:presenter) { MeetingPresenter.new(meeting) }

    it 'renders the meeting card' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_css("[data-test='event']")
      expect(page).to have_link(presenter.name)
    end

    it 'renders venue image for meetings' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_css(%(img[alt="#{meeting.venue.name}"]))
    end

    it 'does not render sponsor logos for meetings' do
      render_inline(described_class.new(event_card: presenter))
      # Venue image has sponsor-sm class, so check for mx-1 spacing (used only by sponsors)
      expect(page).to have_no_css('.mx-1')
    end
  end

  context 'with an event' do
    let(:event) { Fabricate(:event) }
    let(:presenter) { EventPresenter.new(event) }

    it 'renders the event card' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_css("[data-test='event']")
      expect(page).to have_link(event.name)
    end

    it 'renders sponsor logos for events' do
      sponsor = Fabricate(:sponsor)
      event.sponsors << sponsor
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_css(%(img[alt="#{sponsor.name}"]))
    end
  end

  context 'with caching on' do
    let(:fragment_store) { CountingCacheStore.new }

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

    def render_card(record)
      render_inline(described_class.new(event_card: EventPresenter.decorate(record.reload))).to_html
    end

    # None of these records touch the event row when they change, so a key on
    # the event alone kept serving the old fragment until the event itself was
    # edited. Each example pins that the event's own key did not move.
    it 'busts the fragment when the host is renamed without touching the workshop' do
      workshop = Fabricate(:workshop, chapter:)
      before = workshop.reload.cache_key_with_version
      expect(render_card(workshop)).to include(workshop.host.name)

      workshop.host.update!(name: 'Renamed Host')

      expect(workshop.reload.cache_key_with_version).to eq(before)
      expect(render_card(workshop)).to include('Renamed Host')
    end

    it 'busts the fragment when a sponsor is renamed without touching the event' do
      event = Fabricate(:event)
      sponsor = Fabricate(:sponsor)
      event.sponsors << sponsor
      before = event.reload.cache_key_with_version
      expect(render_card(event)).to include(%(alt="#{sponsor.name}"))

      sponsor.update!(name: 'Renamed Sponsor')

      expect(event.reload.cache_key_with_version).to eq(before)
      expect(render_card(event)).to include('alt="Renamed Sponsor"')
    end

    it 'busts the fragment when a sponsor is removed without touching the event' do
      event = Fabricate(:event)
      sponsor = Fabricate(:sponsor)
      event.sponsors << sponsor
      before = event.reload.cache_key_with_version
      expect(render_card(event)).to include(%(alt="#{sponsor.name}"))

      event.sponsors.delete(sponsor)

      expect(event.reload.cache_key_with_version).to eq(before)
      expect(render_card(event)).not_to include(%(alt="#{sponsor.name}"))
    end

    it 'busts the fragment when the chapter is renamed without touching the workshop' do
      workshop = Fabricate(:workshop, chapter:)
      before = workshop.reload.cache_key_with_version
      expect(render_card(workshop)).to include(chapter.name)

      chapter.update!(name: 'Renamed Chapter')

      expect(workshop.reload.cache_key_with_version).to eq(before)
      expect(render_card(workshop)).to include('Renamed Chapter')
    end

    it 'busts the fragment when an organiser is added without touching the workshop' do
      workshop = Fabricate(:workshop, chapter:)
      before = workshop.reload.cache_key_with_version
      render_card(workshop)

      organiser = Fabricate(:member, name: 'Newly', surname: 'Added')
      organiser.add_role(:organiser, workshop)

      expect(workshop.reload.cache_key_with_version).to eq(before)
      expect(render_card(workshop)).to include('Newly Added')
    end

    it 'busts the fragment when a chapter organiser is added to a workshop with none of its own' do
      chapter_organiser = Fabricate(:member, name: 'Chapter', surname: 'Organiser')
      chapter_organiser.add_role(:organiser, chapter)
      workshop = Fabricate(:workshop, chapter:)
      before = workshop.reload.cache_key_with_version
      expect(render_card(workshop)).to include('Chapter Organiser')

      added = Fabricate(:member, name: 'Added', surname: 'Organiser')
      added.add_role(:organiser, chapter)

      expect(workshop.reload.cache_key_with_version).to eq(before)
      expect(render_card(workshop)).to include('Added Organiser')
    end

    it 'busts the fragment when a chapter organiser is removed and no workshop organiser remains' do
      chapter_organiser = Fabricate(:member, name: 'Chapter', surname: 'Organiser')
      chapter_organiser.add_role(:organiser, chapter)
      workshop = Fabricate(:workshop, chapter:)
      expect(render_card(workshop)).to include('Chapter Organiser')

      chapter_organiser.remove_role(:organiser, chapter)

      expect(render_card(workshop)).not_to include('Chapter Organiser')
    end

    it 'busts the fragment when the meeting venue is renamed without touching the meeting' do
      meeting = Fabricate(:meeting)
      before = meeting.reload.cache_key_with_version
      expect(render_card(meeting)).to include(meeting.venue.name)

      meeting.venue.update!(name: 'Renamed Venue')

      expect(meeting.reload.cache_key_with_version).to eq(before)
      expect(render_card(meeting)).to include('Renamed Venue')
    end

    it 'reuses the fragment while nothing rendered has changed' do
      workshop = Fabricate(:workshop, chapter:)
      render_card(workshop)
      expect(fragment_store.writes).to be_positive

      fragment_store.reset_counts!
      render_card(workshop)

      expect(fragment_store.hits).to be_positive
      expect(fragment_store.writes).to be_zero
    end

    it 'keys an event on its sponsors regardless of the order the association returns them' do
      event = Fabricate(:event)
      first = Fabricate(:sponsor)
      second = Fabricate(:sponsor)
      event.sponsors << first << second

      presenter = EventPresenter.decorate(event.reload)
      allow(presenter).to receive(:sponsors).and_return([first, second])
      render_inline(described_class.new(event_card: presenter)).to_html

      allow(presenter).to receive(:sponsors).and_return([second, first])
      fragment_store.reset_counts!
      render_inline(described_class.new(event_card: presenter)).to_html

      expect(fragment_store.hits).to be_positive
      expect(fragment_store.writes).to be_zero
    end
  end

  context 'with a user' do
    let(:workshop) { Fabricate(:workshop, chapter:) }
    let(:presenter) { WorkshopPresenter.new(workshop) }
    let(:member) { Fabricate(:member) }

    it 'renders user-independent output even with a warm cache' do
      Fabricate(:workshop_invitation, workshop:, member:, attending: true)
      cache = ActiveSupport::Cache::MemoryStore.new

      # Regression: user-dependent badges (Attending/Manage) were rendered inside
      # the cached fragment, so an organiser's dashboard render leaked badges to
      # every other user, including signed-out visitors. The card must contain
      # nothing user-specific, ever.
      ActionController::Base.cache_store = cache
      first = render_inline(described_class.new(event_card: presenter)).to_html
      second = render_inline(described_class.new(event_card: presenter)).to_html

      expect(first).not_to include('Attending')
      expect(first).not_to include('Manage')
      expect(first).to eq(second)

      # The fragment key includes I18n.locale, so a render under another locale
      # must not reuse (or poison) the :en fragment.
      begin
        I18n.locale = :fr
        french = render_inline(described_class.new(event_card: presenter)).to_html
        expect(french).not_to eq(first)
      ensure
        I18n.locale = :en
      end
    ensure
      ActionController::Base.cache_store = :null_store
    end

    it 'no longer accepts a user (card must be user-agnostic)' do
      # Pins the fix for #2869: badges rendered behind the removed `user:` kwarg,
      # so a reintroduction must fail loudly here.
      expect { described_class.new(event_card: presenter, user: member) }
        .to raise_error(ArgumentError, /unknown keyword/)
    end
  end
end
