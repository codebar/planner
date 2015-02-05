require 'spec_helper'

describe Sessions, :se => true do
  subject(:session) { Fabricate(:sessions) }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:date_and_time) }
  it { should respond_to(:sponsors) }
  it { should respond_to(:sponsor_sessions)}

  context "#coach_spaces?" do
    let(:sponsor) { Fabricate(:sponsor) }

    before do
      session.sponsor_sessions.delete_all
      Fabricate(:sponsor_session, sponsor: sponsor, sessions: session, host: true)
    end

  end

  context "#scopes" do
    let(:set_upcoming) { 2.times.map { |n| Fabricate(:sessions, date_and_time: DateTime.now+(n+1).week) } }
    let(:most_recent) { Fabricate(:sessions, date_and_time: 1.day.ago) }

    before do
      Fabricate(:sessions, date_and_time: DateTime.now-1.week)
      set_upcoming
      most_recent
    end

    it "#upcoming" do
      expect(Sessions.upcoming.length).to eq(2)
    end

    it "#next" do
      expect(Sessions.next).to eq(set_upcoming.first)
    end

    it "#most_recent" do
      expect(Sessions.most_recent).to eq(most_recent)
    end

    describe "#host" do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        session.sponsor_sessions.delete_all
        Fabricate(:sponsor_session, sponsor: sponsor, sessions: session, host: true)
      end

      it { expect(session.host).to eq(sponsor) }
    end

    context "attendances" do
      let(:sponsor) { Fabricate(:sponsor) }

      before do
        Fabricate(:sponsor_session, sponsor: sponsor, sessions: session, host: true)
      end

      it "#attending_students" do
        3.times { Fabricate(:session_invitation, sessions: session, attending: true) }
        1.times { Fabricate(:session_invitation, sessions: session, attending: false) }

        expect(session.reload.attending_students.length).to eq(3)
      end

      it "#attending_members" do
        2.times { Fabricate(:coach_session_invitation, sessions: session, attending: true) }
        1.times { Fabricate(:coach_session_invitation, sessions: session, attending: false) }

        expect(session.reload.attending_coaches.length).to eq(2)
      end
    end
  end
end
