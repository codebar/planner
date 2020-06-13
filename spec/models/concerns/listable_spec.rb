require 'spec_helper'

RSpec.describe Listable, type: :model do
  subject(:workshop) { Fabricate(:workshop) }

  context 'scopes' do
    context '#upcoming' do
      it 'returns a list of all upcoming workshops' do
        Fabricate.times(5, :past_workshop)
        future_workshops = Fabricate.times(3, :workshop)

        expect(Workshop.upcoming).to match_array(future_workshops)
      end
    end

    context '#past' do
      it 'returns a list of all upcoming workshops' do
        past_workshops = Fabricate.times(5, :past_workshop)
        Fabricate.times(3, :workshop)

        expect(Workshop.past).to match_array(past_workshops)
      end
    end

    context '#recent' do
      it 'returns a list of the last 10 workshops' do
        Fabricate.times(9, :past_workshop)
        Fabricate.times(3, :workshop)
        recent_workshops = 10.times.map do |n|
          Fabricate(:workshop, date_and_time: n.days.ago)
        end

        expect(Workshop.recent).to eq(recent_workshops)
      end
    end

    context '#completed_since_yesterday' do
      it 'returns a list of yesterday\'s events' do
        Fabricate(:workshop, date_and_time: 24.hours.ago)
        Fabricate(:workshop, date_and_time: 25.hours.ago)
        latest = [Fabricate(:workshop, date_and_time: 3.hours.ago),
                  Fabricate(:workshop, date_and_time: 12.hours.ago),
                  Fabricate(:workshop, date_and_time: 23.hours.ago)]

        expect(Workshop.completed_since_yesterday).to eq(latest)
      end
    end
  end

  context '#next' do
    it 'returns the next workshop to take place' do
      next_workshop = Fabricate(:workshop, date_and_time: Time.zone.now + 24.hours)
      Fabricate(:workshop, date_and_time: Time.zone.now + 29.hours)

      expect(Workshop.next).to eq(next_workshop)
    end

    it 'returns the latest workshop to have taken place' do
      past_most_recent_workshop = Fabricate(:workshop, date_and_time: 2.hours.ago)
      Fabricate(:workshop, date_and_time: 5.hours.ago)
      Fabricate(:workshop, date_and_time: 2.days.ago)

      most_recent = Workshop.most_recent
      expect(most_recent).to eq(past_most_recent_workshop)
      expect(most_recent.sponsors).to eq(past_most_recent_workshop.sponsors)
    end
  end
end
