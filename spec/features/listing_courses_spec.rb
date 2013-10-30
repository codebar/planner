require 'spec_helper'

feature 'course listing' do

  let!(:upcoming_course) { Fabricate(:course) }
  let!(:past_course) { Fabricate(:course, date_and_time: DateTime.new-1.week) }

  before do
    visit courses_path
  end

  scenario 'i can view a list with upcoming courses' do

    expect(page).to have_content "Upcoming courses"
    expect(page).to have_content upcoming_course.title
  end

  scenario 'i can view a list with past courses' do

    expect(page).to have_content "Past courses"
    expect(page).to have_content past_course.title
  end
end
