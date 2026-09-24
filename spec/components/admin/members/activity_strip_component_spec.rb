# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Members::ActivityStripComponent do
  let(:member) { Fabricate(:member) }
  let(:now) { Time.zone.local(2026, 9, 2, 12, 0, 0) }
  let(:rows) do
    Admin::Members::ActivityStrip.new(member, now:).tap do |_strip|
      PublicActivity::Activity.create!(
        owner: member, trackable: member, key: 'member.login',
        created_at: now - 1.week, updated_at: now - 1.week
      )
      PublicActivity::Activity.create!(
        owner: member, trackable: member, key: 'event_invitation.rsvp',
        created_at: now - 2.weeks, updated_at: now - 2.weeks
      )
    end.rows
  end

  before { render_inline(described_class.new(weeks: rows)) }

  it 'renders 52 cells' do
    expect(page).to have_css('rect', count: 52)
  end

  it 'renders all three state classes' do
    expect(page).to have_css('.activity-cell-empty')
    expect(page).to have_css('.activity-cell-login_only')
    expect(page).to have_css('.activity-cell-active')
  end

  it 'renders a tooltip with the week and counts' do
    expect(page).to have_css('rect title', text: 'Event invitation rsvp')
  end

  it 'labels each cell with its ISO week' do
    expect(page).to have_css('rect[aria-label]', count: 52)
    expect(page).to have_css("rect[aria-label='#{(now - 2.weeks).to_date.beginning_of_week.strftime('%G-W%V')}']")
    expect(page).to have_css('rect title', text: /^2026-W/)
  end

  it 'renders no tracking marker by default' do
    expect(page).to have_no_css('.activity-tracking-start')
  end

  context 'with a tracking start index' do
    before { render_inline(described_class.new(weeks: rows, tracking_start_index: 10)) }

    it 'renders the marker line centred in the inter-week gap' do
      line = page.find('line.activity-tracking-start')

      expect(line['x1'].to_f).to eq(10 * 12 - 2) # index 10, gap centred
      expect(line['stroke-width'].to_f).to eq(2)
    end

    it 'renders an invisible hover zone carrying the tooltip' do
      hit = page.find('.activity-tracking-start-hit')

      expect(hit['width'].to_f).to eq(10)
      expect(hit['fill']).to eq('transparent').or eq('rgba(0, 0, 0, 0)')
      expect(hit).to have_css('title', text: 'Tracking started 8 Sep 2026')
    end
  end
end
