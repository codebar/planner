require 'spec_helper'

RSpec.feature 'Chapter workshop feedback', type: :feature do
  it 'is only available to chapter organisers' do
    member = Fabricate(:member)
    chapter = Fabricate(:chapter)
    workshop = Fabricate(:workshop, chapter: chapter)
    other_workshop = Fabricate(:workshop)

    feedbacks = Fabricate.times(3, :feedback, workshop: workshop)
    other_feedbacks = Fabricate.times(3, :feedback, workshop: other_workshop)

    login_as_organiser(member, chapter)

    visit root_path
    click_on "#{chapter.name} feedback"

    feedbacks.each { |feedback| expect(page).to have_content(feedback.request) }
    other_feedbacks.each { |feedback| expect(page).to_not have_content(feedback.request) }
  end

  it 'displays a message if no feedback has been submitted yet' do
    member = Fabricate(:member)
    chapter = Fabricate(:chapter)
    login_as_organiser(member, chapter)

    visit root_path
    click_on "#{chapter.name} feedback"

    expect(page).to have_content("No feedback has been submitted for #{chapter.name}'s workshops yet.")
  end
end
