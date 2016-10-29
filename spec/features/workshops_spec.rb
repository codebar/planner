require 'spec_helper'

feature 'Viewing a workshop page' do

  let(:workshop) { Fabricate(:workshop) }
  let(:workshop_auto_rsvp_in_past) { Fabricate(:workshop_auto_rsvp_in_past) }
  let(:workshop_auto_rsvp_in_future) { Fabricate(:workshop_auto_rsvp_in_future) }
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
      context "when invitations have not been sent out" do
        it "can access RSVP as a student" do
          click_on "Attend as a student"
          click_on "Attend"

          expect(page).to have_content("See you at the workshop")
        end

        it "can access RSVP as a coach" do
          click_on "Attend as a coach"
          click_on "Attend"

          expect(page).to have_content("See you at the workshop")
        end

        after do
          visit workshop_path(workshop)
          expect(page).to have_link("Manage your invitation")
        end
      end

      context "when auto RSVP open time is past, invitable turned off" do
        it "can access RSVP as a student" do
          visit workshop_path(workshop_auto_rsvp_in_past)
          click_on "Attend as a student"
          click_on "Attend"

          expect(page).to have_content("See you at the workshop")
        end

        it "can access RSVP as a coach" do
          visit workshop_path(workshop_auto_rsvp_in_past)

          click_on "Attend as a coach"
          click_on "Attend"

          expect(page).to have_content("See you at the workshop")
        end

        after do
          visit workshop_path(workshop_auto_rsvp_in_past)
          expect(page).to have_link("Manage your invitation")
        end
      end

      context "when auto RSVP open time is future, invitable turned off" do
        it "cannot access RSVP as a student or coach" do
          visit workshop_path(workshop_auto_rsvp_in_future)

          expect(page).to have_content("This workshop is not yet open for RSVP.")
        end
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
