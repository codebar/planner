RSpec.describe 'rake reminders:workshop', type: :task do
  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'gracefullies run' do
    travel_to(Time.current) do
      Fabricate(:workshop, date_and_time: 29.hours.from_now)
      expect { task.invoke }.not_to raise_error
    end
  end

  it 'sends out reminders' do
    travel_to(Time.current) do
      workshop = Fabricate(:workshop, date_and_time: 29.hours.from_now)

      invitation_manager = InvitationManager.new
      allow(InvitationManager).to receive(:new).and_return(invitation_manager)
      allow(invitation_manager).to receive(:send_workshop_attendance_reminders).with(workshop)
      allow(invitation_manager).to receive(:send_workshop_waiting_list_reminders).with(workshop)

      task.execute

      expect(InvitationManager).to have_received(:new).twice
      expect(invitation_manager).to have_received(:send_workshop_attendance_reminders).with(workshop)
      expect(invitation_manager).to have_received(:send_workshop_waiting_list_reminders).with(workshop)
    end
  end
end
