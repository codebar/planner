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

    it 'has access to the second page of feedback' do
      feedbacks = Fabricate.times(50, :feedback)

      visit admin_feedback_index_path
      
      # Check if the page has a link with the text '2' that leads to the second page of feedback
      second_page_path = Rails.application.routes.url_for(controller: 'admin/feedback', action: 'index', only_path: true, page: 2)
      expect(page).to have_link('2', href: second_page_path)
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
