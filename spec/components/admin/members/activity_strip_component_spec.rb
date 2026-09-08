# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Members::ActivityStripComponent, type: :component do
  let(:member) { Fabricate(:member) }
  let(:now) { Time.zone.local(2026, 9, 2, 12, 0, 0) }
  let(:rows) do
    Admin::Members::ActivityStrip.new(member, now:).tap do |_strip|
      PublicActivity::Activity.create!(owner: member, trackable: member, key: 'member.login',
                                       created_at: now - 1.week, updated_at: now - 1.week)
      PublicActivity::Activity.create!(owner: member, trackable: member, key: 'event_invitation.rsvp',
                                       created_at: now - 2.weeks, updated_at: now - 2.weeks)
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
    expect(page).to have_css('rect[title*="event_invitation rsvp"]')
  end
end
