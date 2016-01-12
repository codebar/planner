require 'spec_helper'

describe WorkshopPresenter do
  let(:invitations) { [Fabricate(:student_session_invitation),
                       Fabricate(:student_session_invitation),
                       Fabricate(:coach_session_invitation),
                       Fabricate(:coach_session_invitation)
                      ] }
  let(:chapter) { Fabricate(:chapter) }
  let(:sessions) { double(:workshop, attendances: invitations, host: Fabricate(:sponsor), chapter: chapter )}
  let(:workshop) { WorkshopPresenter.new(sessions) }

  it "#venue" do
    expect(sessions).to receive(:host)

    workshop.venue
  end

  it "#organisers" do
    expect(sessions).to receive(:permissions)
    expect(sessions).to receive(:chapter).and_return(chapter)

    workshop.organisers
  end

  it "#time" do
    expect(sessions).to receive(:time).and_return(Time.zone.now)

    workshop.time
  end

  context "#random_allocate_date" do
    it "returns the empty string when no date is set" do
      expect(sessions).to receive(:random_allocate_at).and_return(nil)
      expect(workshop.random_allocate_date).to be == ""
    end

    it "returns a date when a date is set" do
      expect(sessions).to receive(:random_allocate_at).twice.and_return(DateTime.new)
      expect(workshop.random_allocate_date).to match(%r{.*/.*/.*})
    end
  end

  context "#random_allocate_time" do
    it "returns the empty string when no time is set" do
      expect(sessions).to receive(:random_allocate_at).and_return(nil)
      expect(workshop.random_allocate_time).to be == ""
    end

    it "returns a date when a time is set" do
      expect(sessions).to receive(:random_allocate_at).twice.and_return(DateTime.new)
      expect(workshop.random_allocate_time).to match(%r{.*:.*})
    end
  end

  it "#attendees_csv" do
    expect(workshop).to receive(:organisers).at_least(:once).and_return [invitations.last.member]
    expect(workshop.attendees_csv).not_to be_blank

    invitations.each do |invitation|
      expect(workshop.attendees_csv).to include(invitation.member.full_name)
      expect(workshop.attendees_csv).to include(invitation.role.upcase).or include("ORGANISER")
    end
    expect(workshop.attendees_csv).to include("ORGANISER")
    expect(workshop.attendees_csv).to include("STUDENT")
    expect(workshop.attendees_csv).to include("COACH")
  end
end
