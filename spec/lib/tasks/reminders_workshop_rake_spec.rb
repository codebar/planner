require "spec_helper"

describe "reminders:workshop" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }
  let!(:workshop) { Fabricate(:sessions, date_and_time: DateTime.now+29.hours) }

  it 'should gracefully run' do
    expect { subject.invoke }.to_not raise_error
  end

  it "sends out reminders" do
    expect(InvitationManager).to receive(:send_workshop_attendance_reminders).with(workshop)

    subject.invoke
  end
end
