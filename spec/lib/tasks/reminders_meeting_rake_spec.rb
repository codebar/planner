require 'spec_helper'

RSpec.describe 'rake reminders:meeting', type: :task do

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it 'should gracefully run' do
    expect { task.invoke }.to_not raise_error
  end

  it 'sends out reminders for meetings taking place between 6 and 30 hours from now' do
    meeting = Fabricate(:meeting, date_and_time: Time.zone.now + 29.hours)
    just_now_meeting = Fabricate(:meeting, date_and_time: Time.zone.now + 2.hours)
    past_meeting = Fabricate(:meeting, date_and_time: 1.day.ago)

    invitation_manager = InvitationManager.new
    expect(InvitationManager).to receive(:new).and_return(invitation_manager)
    expect(invitation_manager).to receive(:send_monthly_attendance_reminder_emails).with(meeting)
    expect(invitation_manager).to_not receive(:send_monthly_attendance_reminder_emails).with(past_meeting)
    expect(invitation_manager).to_not receive(:send_monthly_attendance_reminder_emails).with(just_now_meeting)

    task.execute
  end
end
