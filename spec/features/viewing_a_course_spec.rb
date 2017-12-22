require 'spec_helper'

feature 'viewing a course' do
  let(:date_and_time) { Time.zone.now + 1.week }
  let!(:course) { Fabricate(:course) }

  scenario "i can view a course's information" do
    visit course_path(course)

    expect(page).to have_content course.title
    expect(page).to have_content course.description
    expect(page).to have_content course.short_description
    expect(page).to have_content course.url

    expect(page).to have_content 'Sign up'
    expect(page).to have_content 'Sign in'
  end
end
