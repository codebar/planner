require 'spec_helper'

describe Reminders do
  let(:session) { Fabricate(:sessions) }

  context "#scopes" do

    it "session" do
      Fabricate(:session_reminder, reminder_id: session.id)

      Reminders.session(session).should_not be nil
    end
  end

  it "adds a reminder for the given session" do
    Reminders.add_for_session(session, 2)

    Reminders.session(session).exists?.should eq true
  end
end
