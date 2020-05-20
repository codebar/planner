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
      context 'a student' do
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

      context 'a coach' do
        let(:invitation) { Fabricate(:coach_workshop_invitation, member: member) }
        let(:note) { 'I am most comfortable with being paired in JavaScript' }

        scenario 'can accept their invitation without a note' do
          visit invitation_route

          click_on 'Attend'

          expect(page).to have_content("Thanks for getting back to us #{member.name}. See you at the workshop!")
          expect(page).to have_field('workshop_invitation_note', with: '')
        end

        scenario 'can accept their invitation with a note' do
          visit invitation_route

          fill_in 'Note', with: note
          click_on 'Attend'

          expect(page).to have_content("Thanks for getting back to us #{member.name}. See you at the workshop!")
          expect(page).to have_field('workshop_invitation_note', with: note)
        end

        scenario 'can update the note on their invitation' do
          note = 'I am most comfortable with being paired in JavaScript'
          invitation.update_attributes(note: 'A note', attending: true)
          visit invitation_route

          expect(page).to have_field('workshop_invitation_note', with: 'A note')

          fill_in 'Note', with: note
          click_on 'Update note'

          expect(page).to have_field('workshop_invitation_note', with: note)
          expect(page).to have_content("Successfully updated note.")
        end
      end
    end
  end
end
