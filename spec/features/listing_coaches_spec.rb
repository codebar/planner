require 'spec_helper'

feature 'when visiting the coaches page' do
  let!(:coach) { Fabricate(:coach_workshop_invitation, attended: true).member }

  scenario 'I can see the most active coaches' do
    visit coaches_path
    expect(page).to have_content coach.name
  end
end
