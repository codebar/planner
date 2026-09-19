require 'rails_helper'

RSpec.describe EventCardComponent do
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

    it 'renders chapter badge' do
      render_inline(described_class.new(event_card: presenter))
      expect(page).to have_link(chapter.name)
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
