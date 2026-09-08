# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Dashboard::ChapterHealth do
  describe '.row' do
    it 'computes a health row for a single chapter' do
      chapter = Fabricate(:chapter)
      Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)
      member = Fabricate(:member)
      member.add_role(:organiser, chapter)

      row = described_class.row(chapter:)

      expect(row.bucket).to eq(:active)
      expect(row.organiser_count).to eq(1)
      expect(row.median_cadence_days).to be_nil
    end

    it 'classifies an idle enabled chapter as dormant' do
      chapter = Fabricate(:chapter)

      row = described_class.row(chapter:)

      expect(row.bucket).to eq(:dormant)
      expect(row.days_since_last_workshop).to be_nil
    end

    it 'classifies a disabled chapter as inactive even with in-window workshops' do
      chapter = Fabricate(:chapter, active: false)
      Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)

      row = described_class.row(chapter:)

      expect(row.bucket).to eq(:inactive)
    end

    it 'counts eligible students and coaches (subscribed, not banned, TOC accepted)' do
      chapter = Fabricate(:chapter)
      Fabricate(:students, chapter:)
      Fabricate(:coaches, chapter:)

      row = described_class.row(chapter:)

      expect(row.eligible_students).to eq(2)
      expect(row.eligible_coaches).to eq(2)
    end

    it 'exposes the days until the next scheduled workshop' do
      chapter = Fabricate(:chapter)
      Fabricate(:workshop, chapter:, date_and_time: 10.days.from_now)

      row = described_class.row(chapter:)

      expect(row.days_until_next_workshop).to eq(10)
    end

    it 'returns nil days_since_last_workshop with no past workshops' do
      chapter = Fabricate(:chapter)

      row = described_class.row(chapter:)

      expect(row.days_since_last_workshop).to be_nil
    end

    it 'computes median cadence between workshops held in the past 180 days' do
      chapter = Fabricate(:chapter)
      Fabricate(:workshop, chapter:, date_and_time: 60.days.ago)
      Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)
      Fabricate(:workshop, chapter:, date_and_time: 10.days.ago)

      row = described_class.row(chapter:)

      expect(row.median_cadence_days).to eq(25)
    end

    it 'returns nil cadence with fewer than two workshops in 180 days' do
      chapter = Fabricate(:chapter)
      Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)

      row = described_class.row(chapter:)

      expect(row.median_cadence_days).to be_nil
    end

    it 'excludes workshops outside 180 days from cadence' do
      chapter = Fabricate(:chapter)
      Fabricate(:workshop, chapter:, date_and_time: 200.days.ago)
      Fabricate(:workshop, chapter:, date_and_time: 30.days.ago)

      row = described_class.row(chapter:)

      expect(row.median_cadence_days).to be_nil
    end
  end
end
