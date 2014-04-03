require 'spec_helper'

feature 'viewing a course' do

  let(:date_and_time) { DateTime.now+1.week }
  let!(:course) { Fabricate(:course) }


  scenario "i can view a course's information" do
    visit course_path(course)

    expect(page).to have_content course.title
    expect(page).to have_content course.description
    expect(page).to have_content course.short_description
    expect(page).to have_content course.url

    expect(page).to have_content "Sign up to receive an invitation to the course."
  end

  context "signing up is not available" do
    scenario "when there are seats left" do
      course.update_attribute(:seats, 0)
      visit course_path(course)

      expect(page).to have_content "This course is fully booked!"
    end
  end
end
