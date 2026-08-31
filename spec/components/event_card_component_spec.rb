require 'rails_helper'

RSpec.describe EventCardComponent, type: :component do
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

    it 'renders attending badge when user is attending (as presenter)' do
      Fabricate(:workshop_invitation, workshop:, member:, attending: true)
      user_presenter = MemberPresenter.new(member)
      render_inline(described_class.new(event_card: presenter, user: user_presenter))
      expect(page).to have_text('Attending')
    end

    it 'renders attending badge when raw Member is passed' do
      Fabricate(:workshop_invitation, workshop:, member:, attending: true)
      render_inline(described_class.new(event_card: presenter, user: member))
      expect(page).to have_text('Attending')
    end
  end
end
