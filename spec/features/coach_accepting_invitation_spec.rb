RSpec.feature 'a Coach can', type: :feature do
  context '#workshop' do
    let(:member) { Fabricate(:member) }
    let(:invitation) { Fabricate(:coach_workshop_invitation, member: member) }
    let(:invitation_route) { invitation_path(invitation) }
    let(:reject_invitation_route) { reject_invitation_path(invitation) }
    let(:accept_invitation_route) { accept_invitation_path(invitation) }

    let(:set_no_available_slots) do
      # Fill up the workshop by creating attending coaches up to capacity
      # This ensures the waiting list/full state is triggered properly
      workshop = invitation.workshop
      capacity = workshop.host.coach_spots
      attending_count = workshop.attending_coaches.count
      spots_to_fill = capacity - attending_count

      spots_to_fill.times do
        member = Fabricate(:member)
        Fabricate(:workshop_invitation, workshop: workshop, member: member, role: 'Coach', attending: true)
      end
    end

    before(:each) do
      login(member)
    end

    it_behaves_like 'invitation route'
  end
end
