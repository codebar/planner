require 'spec_helper'

RSpec.feature 'Viewing feedback', type: :feature do
  let(:member) { Fabricate(:member) }

  context 'an admin' do
    before do
      login_as_admin(member)
    end

    it 'can access the feedback page' do
      feedbacks = Fabricate.times(10, :feedback)

      visit admin_feedback_index_path
      feedbacks.each { |feedback| expect(page).to have_content(feedback.request) }
    end
  end

  context 'an organiser' do
    before do
      login_as_organiser(member, Fabricate(:chapter))
    end

    it 'can not access the feedback page' do
      visit admin_feedback_index_path

      expect(page).to have_content('You can\'t be here')
    end
  end
end
