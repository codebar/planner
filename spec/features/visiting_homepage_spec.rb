require 'spec_helper'

feature 'when visiting the homepage' do

  let!(:next_workshop) { Fabricate(:workshop) }
  let!(:next_course) { Fabricate(:course) }
  let!(:event) { Fabricate(:event) }

  before(:each) do
    visit root_path
  end

  scenario "i can view the next workshop" do

    expect(page).to have_content "Workshop at #{next_workshop.host.name}"
  end

  scenario "i can view the next course" do

    expect(page).to have_content next_course.title
  end

  scenario "i can view upcoming events" do

    expect(page).to have_content event.name
  end

  scenario "i can access the code of conduct" do
    click_on "Code of conduct"

    expect(page).to have_content "Code of conduct"
    expect(page).to have_content "The Quick Version"
    expect(page).to have_content "The Long Version"
  end

  scenario "i can sign in" do
    visit root_path

    expect(page).to have_content "Sign in"
  end

  context "signing up" do
    scenario "i can sign up as a student" do
      visit root_path

      expect(page).to have_content "Learn to code!"
    end

    scenario "i can sign up as a coach" do
      visit root_path

      expect(page).to have_content "Help out by becoming a coach"
    end
  end
end
