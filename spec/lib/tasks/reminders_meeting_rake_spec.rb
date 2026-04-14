RSpec.describe 'rake reminders:meeting', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'gracefullies run' do
    travel_to(Time.current) do
      Fabricate(:meeting, date_and_time: 29.hours.from_now)
      expect { task.invoke }.not_to raise_error
    end
  end

  it 'sends out reminders for meetings taking place between 6 and 30 hours from now' do
    travel_to(Time.current) do
      meeting = Fabricate(:meeting, date_and_time: 29.hours.from_now)
      just_now_meeting = Fabricate(:meeting, date_and_time: 2.hours.from_now)
      past_meeting = Fabricate(:meeting, date_and_time: 1.day.ago)

      invitation_manager = InvitationManager.new
      expect(InvitationManager).to receive(:new).and_return(invitation_manager)
      expect(invitation_manager).to receive(:send_monthly_attendance_reminder_emails).with(meeting)
      expect(invitation_manager).not_to receive(:send_monthly_attendance_reminder_emails).with(past_meeting)
      expect(invitation_manager).not_to receive(:send_monthly_attendance_reminder_emails).with(just_now_meeting)

      task.execute
    end
  end
end
