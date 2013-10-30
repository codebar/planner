require 'spec_helper'

feature 'viewing a course' do

  let(:date_and_time) { DateTime.now+1.week }
  let!(:course) { Fabricate(:course) }

  scenario "i can view a course's information" do
    visit root_path

    click_on "Courses"
    click_on course.title

    expect(page).to have_content course.title
    expect(page).to have_content course.tutor.full_name
    expect(page).to have_content course.description
    expect(page).to have_content course.short_description
    expect(page).to have_content course.url
  end
end

