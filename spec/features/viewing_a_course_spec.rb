require 'spec_helper'

RSpec.feature 'viewing a course', type: :feature do
  let(:date_and_time) { Time.zone.now + 1.week }
  let!(:course) { Fabricate(:course) }

  scenario "i can view a course's information" do
    visit course_path(course)

    expect(page).to have_content course.title
    expect(page).to have_content I18n.l(course.date_and_time, format: :_humanize_date_with_time)
    expect(page).to have_content course.description
    expect(page).to have_content course.short_description
    expect(page).to have_link "Read more", href: course.url

    expect(page).to have_content 'Sign up'
    expect(page).to have_content 'Sign in'
  end
end
