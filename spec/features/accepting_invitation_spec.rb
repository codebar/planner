require 'spec_helper'

feature 'a member can' do

  context "#session" do
    let(:invitation) { Fabricate(:session_invitation) }
    let(:invitation_route) { invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.sessions.host.update_attribute(:seats, 0) }

    it_behaves_like "invitation route"

  end

  context "#course" do
    let(:invitation) { Fabricate(:course_invitation) }
    let(:accepting_invitation_path) { accept_course_invitation_path(invitation) }
    let(:rejecting_invitation_path) { reject_course_invitation_path(invitation) }

    let(:set_no_available_slots) { invitation.course.update_attribute(:seats, 0) }

    context "accept an invitation" do
      scenario 'when there are available spots' do
        visit accepting_invitation_path

        expect(current_url).to eq(root_url)
        expect(page).to have_content("Thanks for getting back to us #{invitation.member.name}.")
      end

      scenario 'when they have already confirmed their attendance' do
        invitation.update_attribute(:attending, true)
        visit accepting_invitation_path

        expect(current_url).to eq(root_url)
        expect(page).to have_content("You have alredy confirmed you attendance!")
      end

      scenario 'when there are no available spots' do
        set_no_available_slots
        visit accepting_invitation_path

        expect(current_url).to eq(root_url)
        expect(page).to have_content("Unfortunately there are no more spaces left :(.")
      end
    end

    context "reject an invitation" do
      scenario 'when they are succesful' do
        invitation.update_attribute(:attending, true)
        visit rejecting_invitation_path

        expect(current_url).to eq(root_url)
        expect(page).to have_content(I18n.t("messages.rejected_invitation", name: invitation.member.name))
      end

      scenario 'when already confirmed' do
        invitation.update_attribute(:attending, false)
        visit rejecting_invitation_path

        expect(current_url).to eq(root_url)
        expect(page).to have_content(I18n.t("messages.not_attending_already"))
      end

    end
  end
end
