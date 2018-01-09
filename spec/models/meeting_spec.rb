require 'spec_helper'

describe Meeting do
  context 'validations' do
    subject { Meeting.new }

    it '#date_and_time' do
      should have(1).error_on(:date_and_time)
    end

    it '#venue' do
      should have(1).error_on(:venue)
    end
  end

  context '#title' do
    subject(:meeting) { Meeting.new(date_and_time: Time.zone.local(2014, 8, 20, 18, 30)) }

    it 'is formatted correctly' do
      expect(meeting.title).to eq('August Meeting')
    end
  end
end
