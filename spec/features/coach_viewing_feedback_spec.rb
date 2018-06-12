require 'spec_helper'

feature 'Coach viewing feedback' do
  it 'can access all feedback' do
    coach = Fabricate(:workshop_coach_attendee, name: 'Le name one')
    Fabricate(:coaches, members: [coach])
    feedbacks = Fabricate.times(3, :feedback, coach: nil)

    login(coach)

    visit coach_feedback_index_path
    feedbacks.each { |feedback| expect(page).to have_content(feedback.request) }
  end

  it 'views their feedback highlighted but anonymously' do
    other_coach = Fabricate(:workshop_coach_attendee, name: 'Le other name')
    coach = Fabricate(:workshop_coach_attendee)
    Fabricate(:coaches, members: [coach, other_coach])
    other_feedback = Fabricate(:feedback, coach: other_coach)
    feedback = Fabricate(:feedback, coach: coach)

    login(coach)

    visit coach_feedback_index_path
    within '.callout' do
      expect(page).to have_content(feedback.request)
      expect(page).to_not have_content(other_feedback.request)
    end
    expect(page).to have_content(other_feedback.request)

    expect(page).to_not have_content(coach.name)
    expect(page).to_not have_content(other_coach.name)
  end
end
