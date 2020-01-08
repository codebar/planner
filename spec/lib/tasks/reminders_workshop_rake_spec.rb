require 'spec_helper'

RSpec.describe 'rake reminders:workshop', type: :task do
  let!(:workshop) { Fabricate(:workshop, date_and_time: Time.zone.now + 29.hours) }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it 'should gracefully run' do
    expect { task.invoke }.to_not raise_error
  end

  it 'sends out reminders' do
    invitation_manager = InvitationManager.new
    expect(InvitationManager).to receive(:new).and_return(invitation_manager)
    expect(invitation_manager).to receive(:send_workshop_attendance_reminders).with(workshop)

    expect(InvitationManager).to receive(:new).and_return(invitation_manager)
    expect(invitation_manager).to receive(:send_workshop_waiting_list_reminders).with(workshop)

    task.execute
  end
end
