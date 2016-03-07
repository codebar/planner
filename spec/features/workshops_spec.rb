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

    context "#past events" do
      let!(:workshop) { Fabricate(:workshop, date_and_time: 2.weeks.ago) }

      scenario "cannot interact with a past event" do

        expect(page).to have_content("has already taken place")
      end
    end

  end
end
