require 'spec_helper'

describe Reminders do
  let(:session) { Fabricate(:sessions) }

  context "#scopes" do

    it "session" do
      Fabricate(:session_reminder, reminder_id: session.id)

      expect(Reminders.session(session)).to_not be(nil)
    end
  end

  it "adds a reminder for the given session" do
    Reminders.add_for_session(session, 2)

    expect(Reminders.session(session).exists?).to eq(true)
  end
end
