require 'spec_helper'

RSpec.describe Meeting, type: :model  do
  include_examples "Invitable", :meeting_invitation, :meeting
  include_examples DateTimeConcerns, :meeting

  context 'validations' do
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
