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
