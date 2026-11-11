# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChapterSignUpsPresenter do
  subject(:by_month) { described_class.new(chapter).by_month }

  around do |example|
    travel_to(Time.zone.local(2026, 11, 6, 12, 0)) { example.run }
  end

  let(:chapter) { Fabricate(:chapter) }
  let(:students) { Fabricate(:group, name: 'Students', chapter:) }
  let(:coaches) { Fabricate(:group, name: 'Coaches', chapter:) }

  def students_in(month)
    by_month.find { |row| row[:month] == month }.fetch(:students)
  end

  def coaches_in(month)
    by_month.find { |row| row[:month] == month }.fetch(:coaches)
  end

  it 'returns the last three months in ascending order' do
    expect(by_month.map { |row| row[:month] })
      .to eq([Date.new(2026, 9, 1), Date.new(2026, 10, 1), Date.new(2026, 11, 1)])
  end

  it 'splits sign-ups into students and coaches' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 9, 10))
    Fabricate(:subscription, group: coaches, created_at: Time.zone.local(2026, 9, 11))
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 11, 2))

    expect(by_month).to eq([
                             { month: Date.new(2026, 9, 1), students: 1, coaches: 1 },
                             { month: Date.new(2026, 10, 1), students: 0, coaches: 0 },
                             { month: Date.new(2026, 11, 1), students: 1, coaches: 0 }
                           ])
  end

  it 'ignores sign-ups from other chapters' do
    other_chapter = Fabricate(:chapter_with_groups)
    other_chapter.groups.each do |group|
      Fabricate(:subscription, group:, created_at: Time.zone.local(2026, 10, 5))
    end

    expect(by_month.sum { |row| row[:students] + row[:coaches] }).to eq(0)
  end

  it 'ignores sign-ups older than the window' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 8, 31, 23, 30))

    expect(by_month.sum { |row| row[:students] }).to eq(0)
  end

  it 'ignores sign-ups after the current month' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 12, 1, 0, 30))

    expect(by_month.sum { |row| row[:students] }).to eq(0)
  end

  it 'counts a sign-up on the first instant of the oldest month' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 9, 1, 0, 0))

    expect(students_in(Date.new(2026, 9, 1))).to eq(1)
  end

  it 'ignores rows dated after now' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 11, 6, 11, 59))
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 11, 6, 12, 1))

    expect(students_in(Date.new(2026, 11, 1))).to eq(1)
  end

  it 'counts a member who left and rejoined in the same month once' do
    member = Fabricate(:member)
    Fabricate(:subscription, member:, group: students, created_at: Time.zone.local(2026, 9, 3),
                             discarded_at: Time.zone.local(2026, 9, 20))
    Fabricate(:subscription, member:, group: students, created_at: Time.zone.local(2026, 9, 25))

    expect(students_in(Date.new(2026, 9, 1))).to eq(1)
  end

  it 'counts a member who rejoined in a later month in both months' do
    member = Fabricate(:member)
    Fabricate(:subscription, member:, group: students, created_at: Time.zone.local(2026, 9, 3),
                             discarded_at: Time.zone.local(2026, 9, 20))
    Fabricate(:subscription, member:, group: students, created_at: Time.zone.local(2026, 10, 2))

    expect(students_in(Date.new(2026, 9, 1))).to eq(1)
    expect(students_in(Date.new(2026, 10, 1))).to eq(1)
  end

  it 'matches group names case-insensitively' do
    group = Fabricate(:group, name: 'Students', chapter:)
    group.update_column(:name, 'students')
    Fabricate(:subscription, group:, created_at: Time.zone.local(2026, 10, 5))

    expect(students_in(Date.new(2026, 10, 1))).to eq(1)
  end

  it 'ignores sign-ups from groups that are neither students nor coaches' do
    mentors = Fabricate(:group, name: 'Students', chapter:)
    mentors.update_column(:name, 'Mentors')
    Fabricate(:subscription, group: mentors, created_at: Time.zone.local(2026, 10, 5))

    expect(by_month.sum { |row| row[:students] + row[:coaches] }).to eq(0)
  end

  it 'ignores a group without a name instead of raising' do
    unnamed = Fabricate(:group, name: 'Students', chapter:)
    unnamed.update_column(:name, nil)
    Fabricate(:subscription, group: unnamed, created_at: Time.zone.local(2026, 10, 5))

    expect(by_month.sum { |row| row[:students] + row[:coaches] }).to eq(0)
  end

  it 'starts the window at the first moment of the oldest month in the chapter zone' do
    berlin = Fabricate(:chapter, time_zone: 'Berlin')
    group = Fabricate(:group, name: 'Students', chapter: berlin)
    # 23:30 in London on 31 August is 00:30 in Berlin on 1 September.
    Fabricate(:subscription, group:, created_at: Time.zone.local(2026, 8, 31, 23, 30))

    rows = described_class.new(berlin).by_month.to_h { |row| [row[:month], row[:students]] }

    expect(rows[Date.new(2026, 9, 1)]).to eq(1)
  end

  it 'falls back to the app time zone when the chapter time zone no longer resolves' do
    chapter.update_column(:time_zone, 'Invalid/Zone')
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 10, 5))

    expect(students_in(Date.new(2026, 10, 1))).to eq(1)
  end

  it 'counts a sign-up in the first hour of a BST month in that month' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 10, 1, 0, 30))

    expect(students_in(Date.new(2026, 10, 1))).to eq(1)
    expect(students_in(Date.new(2026, 9, 1))).to eq(0)
  end

  it 'counts a churned member in the month they signed up' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 9, 10),
                             discarded_at: Time.zone.local(2026, 10, 3))

    expect(students_in(Date.new(2026, 9, 1))).to eq(1)
    expect(students_in(Date.new(2026, 10, 1))).to eq(0)
  end

  it 'ignores backfilled tombstones, which carry the unsubscribe time in created_at' do
    Fabricate(:subscription, group: students, created_at: Time.zone.local(2026, 10, 3),
                             discarded_at: Time.zone.local(2026, 10, 3))

    expect(by_month.sum { |row| row[:students] }).to eq(0)
  end

  it 'buckets by the chapter time zone rather than the app time zone' do
    berlin = Fabricate(:chapter, time_zone: 'Berlin')
    group = Fabricate(:group, name: 'Students', chapter: berlin)
    # 23:30 in London on 30 September is 00:30 in Berlin on 1 October.
    Fabricate(:subscription, group:, created_at: Time.zone.local(2026, 9, 30, 23, 30))

    rows = described_class.new(berlin).by_month.to_h { |row| [row[:month], row[:students]] }

    expect(rows[Date.new(2026, 10, 1)]).to eq(1)
    expect(rows[Date.new(2026, 9, 1)]).to eq(0)
  end
end
