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

  it '#slug' do
    meeting = Fabricate(:meeting, slug: 'meeting')
    new_meeting = Fabricate.build(:meeting, slug: 'meeting')
    new_meeting.valid?

    expect(new_meeting.errors.messages[:slug].first).to eq("has already been taken")
  end

  context '#title' do
    subject(:meeting) { Meeting.new(date_and_time: Time.zone.local(2014, 8, 20, 18, 30)) }

    it 'is formatted correctly' do
      expect(meeting.title).to eq('August Meeting')
    end
  end

  context '#set_slug' do
    it 'loops until it finds an available slug' do
      Fabricate.times(4, :meeting, name: 'monthly')
      meeting = Fabricate(:meeting, name: 'monthly')
      expect(meeting.slug)
        .to eq("#{I18n.l(meeting.date_and_time, format: :year_month).downcase}-monthly-5")
    end
  end
end
