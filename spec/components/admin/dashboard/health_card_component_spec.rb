# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Dashboard::HealthCardComponent, type: :component do
  let(:chapter) { Fabricate(:chapter) }

  it 'renders the six stat tiles with formatted values' do
    Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)
    health = Admin::Dashboard::ChapterHealth.row(chapter:)

    render_inline(described_class.new(health:))

    expect(page).to have_text('Chapter Health')
    expect(page).to have_css('.badge', text: 'active')
    expect(page).to have_text('30 days ago')
    expect(page).to have_text('never', count: 0)
    expect(page).to have_text('Cadence (days, median, 180d)')
    expect(page).to have_text('Organisers')
  end

  it 'renders never/none fallbacks for a chapter without workshops' do
    health = Admin::Dashboard::ChapterHealth.row(chapter:)

    render_inline(described_class.new(health:))

    expect(page).to have_css('.badge', text: 'dormant')
    expect(page).to have_text('never')
    expect(page).to have_text('none')
  end

  it 'classifies a disabled chapter as inactive' do
    chapter = Fabricate(:chapter, active: false)
    health = Admin::Dashboard::ChapterHealth.row(chapter:)

    render_inline(described_class.new(health:))

    expect(page).to have_css('.badge', text: 'inactive')
  end

  it 'renders the yielded content inside the card' do
    health = Admin::Dashboard::ChapterHealth.row(chapter:)

    render_inline(described_class.new(health:)) { 'TIMELINE-CONTENT' }

    expect(page).to have_text('TIMELINE-CONTENT')
  end
end
