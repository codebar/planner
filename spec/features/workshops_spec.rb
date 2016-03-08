require 'spec_helper'

feature 'Viewing a workshop page' do

  let(:workshop) { Fabricate(:workshop) }
  let(:member) { Fabricate(:member) }

  context "visitor" do
    scenario "can view a workshop" do
      visit workshop_path(workshop)

      expect(page).to be
    end

    scenario "can sign up or sign in" do
      visit workshop_path workshop

      expect(page).to have_content("Sign up")
      expect(page).to have_content("Log in")
    end
  end

  context "logged in member" do
    before do
      login(member)
      visit workshop_path(workshop)
    end

    context "#upcoming workshop" do
      it "can get to the student and coach invitation pages" do

        expect(page).to have_link("Attend as a student")
        expect(page).to have_link("Attend as a coach")
      end

      context "when invitations have been sent out" do
        let!(:invitation) { Fabricate(:attending_session_invitation, member: member, workshop: workshop) }

        it "can manage vie details if they are already attending" do
          visit workshop_path(workshop)

          expect(page).to have_link("Manage your invitation")
        end
      end
    end

    context "#past events" do
      let!(:workshop) { Fabricate(:workshop, date_and_time: 2.weeks.ago) }

      scenario "cannot interact with a past event" do

        expect(page).to have_content("has already taken place")
      end
    end
  end
end
