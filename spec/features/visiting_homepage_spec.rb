require 'spec_helper'

RSpec.feature 'when visiting the homepage', type: :feature do
  let!(:next_workshop) { Fabricate(:workshop) }
  let!(:next_course) { Fabricate(:course) }
  let!(:events) { Fabricate.times(8, :event) }

  before(:each) do
    visit root_path
  end

  scenario 'the correct page title is rendered' do
    expect(page).to have_title('Homepage | codebar.io')
  end

  scenario 'i can view the next workshop' do
    expect(page).to have_content "Workshop at #{next_workshop.host.name}"
  end

  scenario 'i can view the next course' do
    expect(page).to have_content next_course.title
  end

  scenario 'i can view the next 5 upcoming events' do
    events.take(5).each { |event| expect(page).to have_content "#{event.name} at #{event.venue.name}" }
  end

  scenario 'i can access the code of conduct' do
    click_on 'Code of conduct'

    expect(page).to have_content 'Code of conduct'
    expect(page).to have_content 'The Quick Version'
    expect(page).to have_content 'The Long Version'
  end

  scenario 'I can only view active chapters' do
    inactive_chapters = Fabricate.times(3, :chapter, active: false)
    active_chapters = Fabricate.times(4, :chapter)

    visit root_path

    active_chapters.each do |chapter|
      expect(page).to have_content(chapter.name)
    end

    inactive_chapters.each do |chapter|
      expect(page).to_not have_content(chapter.name)
    end
  end

  scenario 'i can sign in' do
    visit root_path

    expect(page).to have_content 'Sign in'
  end

  context 'signing up' do
    scenario 'i can sign up as a student' do
      visit root_path

      expect(page).to have_content 'Sign up as a student'
    end

    scenario 'i can sign up as a coach' do
      visit root_path

      expect(page).to have_content 'Sign up as a coach'
    end
  end
end
