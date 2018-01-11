require 'spec_helper'

describe FeedbackHelper do
  describe '#recent_workshop_details', type: :helper do
    it 'gets the recently held workshop details' do
      chapters = [Fabricate(:chapter_with_groups, name: 'London'),
                  Fabricate(:chapter_with_groups, name: 'Brighton')]

      workshops = 2.times.map { |n| Fabricate(:workshop, chapter: chapters.sample, date_and_time: Time.zone.now - n.weeks) }

      expect(helper.recent_workshop_details.keys).to eq(workshops.collect(&:id))
    end
  end
end
