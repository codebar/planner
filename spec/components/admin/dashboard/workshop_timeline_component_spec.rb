# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Dashboard::WorkshopTimelineComponent, type: :component do
  it 'renders a heading and legend' do
    render_inline(described_class.new(past: [], future: []))

    expect(page).to have_text('Workshops and events timeline')
    expect(page).to have_text('workshop')
    expect(page).to have_text('planned workshop')
    expect(page).to have_text('chapter event')
    expect(page).to have_text('planned event')
  end

  it 'renders today at 2/3 of the axis (180 days past, 90 days future)' do
    render_inline(described_class.new(past: [], future: []))

    expect(page).to have_css("line[stroke-dasharray][x1='667']")
  end

  it 'places a filled marker for each held workshop with a date tooltip' do
    past = [5.months.ago, 2.months.ago]

    render_inline(described_class.new(past:, future: []))

    expect(page).to have_css("svg[role='img'] circle.marker", count: 2)
    expect(page).to have_css('circle title', text: past.first.to_date.to_fs(:iso8601))
  end

  it 'places planned workshops as hollow markers after today' do
    future = [3.weeks.from_now]

    render_inline(described_class.new(past: [], future:))

    expect(page).to have_css("svg[role='img'] circle.marker[stroke='#0d6efd'][fill='white']", count: 1)
  end

  it 'renders single-chapter events as amber squares, hollow when planned' do
    render_inline(described_class.new(past: [], future: [],
                                      event_past: [40.days.ago],
                                      event_future: [3.weeks.from_now]))

    expect(page).to have_css("svg[role='img'] rect.marker[fill='#fd7e14']", count: 1)
    expect(page).to have_css("svg[role='img'] rect.marker[stroke='#fd7e14'][fill='white']", count: 1)
  end

  it 'stacks same-day workshops with an xN count' do
    same_day = 2.months.ago

    render_inline(described_class.new(past: [same_day, same_day + 1.hour], future: []))

    expect(page).to have_css('text', text: 'x2')
    expect(page).to have_css("svg[role='img'] circle.marker", count: 2)
  end

  it 'caps the stack at three markers so they stay inside the viewBox' do
    same_day = 2.months.ago
    five = (0..4).map { |i| same_day + i.hours }

    render_inline(described_class.new(past: five, future: []))

    expect(page).to have_css('text', text: 'x5')
    expect(page).to have_css("svg[role='img'] circle.marker", count: 3)
    ys = page.all("svg[role='img'] circle.marker").map { |c| c['cy'].to_f }
    expect(ys).to all(be_between(0, 122))
  end

  it 'labels every third month' do
    render_inline(described_class.new(past: [], future: []))

    expect(page).to have_css('text', minimum: 6)
  end
end
