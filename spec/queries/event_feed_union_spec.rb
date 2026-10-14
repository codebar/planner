require 'rails_helper'

RSpec.describe EventFeedUnion do
  describe '.call' do
    it 'includes upcoming meetings, events, and active-chapter workshops' do
      now = Time.zone.now
      workshop = Fabricate(:workshop, date_and_time: now + 2.days, ends_at: now + 2.days + 2.hours)
      meeting = Fabricate(:meeting, date_and_time: now + 1.day, ends_at: now + 1.day + 2.hours)
      event = Fabricate(:event, date_and_time: now + 3.days)
      Fabricate(:workshop, chapter: Fabricate(:chapter, active: false),
                           date_and_time: now + 4.days,
                           ends_at: now + 4.days + 2.hours)
      Fabricate(:meeting, date_and_time: now - 1.day)
      Fabricate(:event, date_and_time: now - 2.days)

      rows = event_rows(upcoming: true)

      expect(rows).to contain_exactly(
        ['Workshop', workshop.id],
        ['Meeting', meeting.id],
        ['Event', event.id]
      )
    end

    it 'includes past meetings, events, and active-chapter workshops' do
      now = Time.zone.now
      workshop = Fabricate(:workshop, date_and_time: now - 2.days, ends_at: now - 2.days + 2.hours)
      meeting = Fabricate(:meeting, date_and_time: now - 1.day)
      event = Fabricate(:event, date_and_time: now - 3.days)
      Fabricate(:workshop, chapter: Fabricate(:chapter, active: false),
                           date_and_time: now - 4.days,
                           ends_at: now - 4.days + 2.hours)
      Fabricate(:meeting, date_and_time: now + 1.day)
      Fabricate(:event, date_and_time: now + 2.days)

      rows = event_rows(upcoming: false)

      expect(rows).to contain_exactly(
        ['Workshop', workshop.id],
        ['Meeting', meeting.id],
        ['Event', event.id]
      )
    end
  end

  def event_rows(upcoming:)
    union = described_class.call(upcoming:)
    ActiveRecord::Base.connection.select_all(union.to_sql).map do |row|
      [row.fetch('event_type'), row.fetch('id').to_i]
    end
  end
end
