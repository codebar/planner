require 'spec_helper'

describe Meeting do
  context "validations" do
    subject { Meeting.new duration: nil }

    it "#date_and_time" do
      should have(1).error_on(:date_and_time)
    end

    it "#duration" do
      should have(1).error_on(:duration)
    end

    it "#lanyrd_url" do
      should have(1).error_on(:lanyrd_url)
    end

    it "#venue" do
      should have(1).error_on(:venue)
    end
  end

  context "#title" do
    subject(:meeting) { Meeting.new(date_and_time: Time.zone.local(2014,8,20,18,30)) }

    it "is formatted correctly" do
      expect(meeting.title).to eq("August Meeting")
    end
  end

  context "#end_time" do
    subject(:meeting) { Meeting.new(date_and_time: Time.zone.local(2014,8,20,18,30)) }

    it "defaults to two hours after the meeting starts" do
      expect(meeting.end_time).to eq(Time.zone.local(2014,8,20,20,30))
    end
  end
end
