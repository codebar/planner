require 'spec_helper'

RSpec.feature 'Accepting a workshop invitation', type: :feature do
  context '#workshop' do
    let(:member) { Fabricate(:member) }
    let(:invitation) { Fabricate(:workshop_invitation, member: member) }
    let(:invitation_route) { invitation_path(invitation) }
    let(:accept_invitation_route) { accept_invitation_path(invitation) }
    let(:reject_invitation_route) { reject_invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.workshop.host.update_attribute(:seats, 0) }

    before(:each) do
      login(member)
    end

    it_behaves_like 'invitation route'

    context 'amend invitation details' do
      scenario 'logged in user with accepted invitation can edit the note' do
        tutorial = Tutorial.create(title: 'Lesson 1 - Introducing HTML')
        invitation.update_attribute(:attending, true)
        visit invitation_route

        select tutorial.title, from: 'note'
        click_on 'Update note'

        expect(page).to have_content('Successfully updated note.')
      end

      scenario 'logged in user with accepted invitation errors without note' do
        invitation.update_attribute(:attending, true)
        visit invitation_route

        click_on 'Update note'

        expect(page).to have_content('You must select a note')
      end
    end
  end
end
