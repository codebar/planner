require 'spec_helper'

RSpec.describe Meeting, type: :model  do
  include_examples "Invitable", :meeting_invitation, :meeting

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

    expect(new_meeting.errors.messages[:slug].first).to eq('has already been taken')
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

  context '#date' do
    it 'returns the date of the meeting in :dashboard format' do
      meeting = Fabricate(:meeting, date_and_time: Time.zone.local(2018, 8, 22, 18, 30))

      expect(meeting.date).to eq('Wednesday, Aug 22')
    end
  end

  context '#not_full' do
    it 'returns true if meeting is not full' do
      meeting = Fabricate(:meeting)
      Fabricate(:attending_meeting_invitation, meeting: meeting)

      expect(meeting.not_full).to eq(true)
    end

    it 'returns false if meeting is full' do
      meeting = Fabricate(:meeting)
      Fabricate.times(21, :attending_meeting_invitation, meeting: meeting)

      expect(meeting.not_full).to eq(false)
    end
  end

  context '#past?' do
    it 'checks whether the meeting already happened' do
      meeting = Fabricate(:meeting, date_and_time: Time.zone.local(2018, 8, 20, 18, 30))

      expect(meeting.past?).to eq(true)
    end
  end

  context '#attendees_csv' do
    it 'generates a csv of attendees' do
      meeting = Fabricate(:meeting)
      invitations = Fabricate.times(2, :attending_meeting_invitation, meeting: meeting)

      expect(meeting.attendees_csv).not_to be_blank
      invitations.each do |invitation|
        expect(meeting.attendees_csv).to include(invitation.member.full_name)
      end
    end
  end
end
