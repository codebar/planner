# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Members::ActivityStrip do
  let(:member) { Fabricate(:member) }
  let(:now) { Time.zone.local(2026, 9, 2, 12, 0, 0) } # Wednesday, current week starts Mon 31 Aug
  let(:strip) { described_class.new(member, now:) }

  def activity_at(time, key: 'member.login')
    PublicActivity::Activity.create!(owner: member, key:, trackable: member,
                                     created_at: time, updated_at: time)
  end

  it 'returns 52 rows oldest first' do
    rows = strip.rows

    expect(rows.size).to eq(52)
    expect(rows.first.week_start).to eq(Time.zone.local(2025, 9, 8))
    expect(rows.last.week_start).to eq(Time.zone.local(2026, 8, 31))
  end

  it 'marks weeks with no rows as empty' do
    expect(strip.rows.map(&:state)).to all(eq(:empty))
  end

  it 'marks login-only weeks as login_only' do
    activity_at(now - 2.weeks, key: 'member.login')

    expect(strip.rows[-3].state).to eq(:login_only)
  end

  it 'marks weeks with any non-login key as active' do
    activity_at(now - 2.weeks, key: 'event_invitation.rsvp')

    expect(strip.rows[-3].state).to eq(:active)
  end

  it 'counts keys for tooltips' do
    activity_at(now - 1.week, key: 'member.login')
    activity_at(now - 1.week, key: 'event_invitation.rsvp')

    expect(strip.rows[-2].counts).to eq('member.login' => 1, 'event_invitation.rsvp' => 1)
  end

  it 'buckets by ISO week with the boundary at window start' do
    activity_at(strip.rows.first.week_start) # exactly at the window edge
    activity_at(strip.rows.first.week_start - 1.second) # one second before: outside

    expect(strip.rows.first.state).to eq(:login_only)
  end
end
