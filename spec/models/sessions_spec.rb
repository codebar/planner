require 'spec_helper'

describe Sessions do
  subject(:session) { Fabricate.build(:sessions) }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:date_and_time) }
  it { should respond_to(:seats) }
  it { should respond_to(:sponsors) }
  it { should respond_to(:sponsor_sessions)}

  context "#scopes" do
    it "#upcoming" do
      Sessions.create date_and_time: DateTime.now-1.week
      2.times { |n| Sessions.create date_and_time: DateTime.now+(n+1).week }

      Sessions.upcoming.length.should eq 2
    end
  end

  it "#attending" do
    3.times { Fabricate(:session_invitation, sessions: session, attending: true) }
    1.times { Fabricate(:session_invitation, sessions: session, attending: false) }

    session.reload.attending_invitations.length.should eq 3
  end
end
