require 'spec_helper'

feature 'Viewing a workshop page' do

  let(:workshop) { Fabricate(:sessions) }
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

    scenario "can view extra session details" do
      content = Faker::Lorem.paragraph
      workshop.update_attribute(:invite_note, content)

      visit workshop_path workshop
      expect(page).to have_content(content)
    end
  end

  xcontext "logged in member" do
    before do
      login(member)
      visit workshop_path(workshop)
    end

    context "#past events" do
      let!(:workshop) { Fabricate(:sessions, date_and_time: 2.weeks.ago) }

      scenario "cannot interact with a past event" do

        expect(page).to have_content("has already taken place")
      end
    end

    context "#upcoming events" do
      context "#not invitable" do
        let(:workshop) { Fabricate(:sessions, invitable: false) }

        scenario "RSVP is not available" do
          visit workshop_path workshop

          expect(page).to have_content("Registrations are not yet available.")
        end
      end

      context "roles" do
        context "student" do
          context "when RSVP is available" do
            let(:workshop) { Fabricate(:sessions, rsvp_close_time: 2.hours.from_now) }

            scenario "can RSVP to a workshop" do
              click_on "Attend as a student"

              expect(page).to have_content("You're coming to Codebar!")
              expect(current_path).to eq(added_workshop_path workshop)
            end

            scenario "can cancel their RSVP" do
              click_on "Attend as a student"
              visit workshop_path(workshop)
              click_on "Cancel your attendance"

              expect(page).to have_content("Sorry to see you go")
            end
          end

          context "when RSVP is closed" do
            let!(:workshop) { Fabricate(:sessions, rsvp_close_time: 2.hours.ago) }
            let!(:invitation) { Fabricate(:attending_session_invitation, member: member, sessions: workshop) }

            scenario "they cannot update their attendance" do
              visit workshop_path(workshop)

              expect(page).to have_content "If you can no longer make it, please send us an email"
            end

          end
        end

        context "#waiting list" do
          context "when there are no spots available" do
            let!(:workshop) { Fabricate(:sessions_no_spots) }

            scenario "can join the waiting list" do
              click_button "Join the student waiting list"

              expect(current_path).to eq(waitlisted_workshop_path workshop)
            end

            scenario "can remove themselves from the waiting list" do
              click_button "Join the student waiting list"

              visit workshop_path(workshop)
              click_on "Remove from Waiting list"

              expect(current_path).to eq(removed_workshop_path workshop)
            end
          end
        end

        context "coach" do
          scenario "can RSVP to a workshop" do
            click_button "Attend as a coach"

            expect(page).to have_content("You're coming to Codebar!")
            expect(current_path).to eq(added_workshop_path workshop)
          end

          scenario "can cancel their RSVP" do
            click_on "Attend as a coach"
            visit workshop_path(workshop)

            click_on "Cancel your attendance"
            expect(page).to have_content("Sorry to see you go")
          end

          #expect(page).to have_content "If you can no longer make it, please send us an email at #{workshop.chapter.email}"

          context "#waiting list" do
            context "when there are no spots available" do
              let(:workshop) { Fabricate(:sessions_no_spots) }

              scenario "they can join the waiting list" do
                click_button "Join the coach waiting list"

                expect(current_path).to eq(waitlisted_workshop_path workshop)
              end
            end
          end
        end
      end
    end
  end
end
