require 'spec_helper'

feature 'member feedback' do
  let(:valid_token) { Fabricate(:feedback_request).token }
  let(:invalid_token) { 'feedback_invalid_token' }
  let(:feedback_submited_message) { I18n.t("messages.feedback_saved") }
  
  before do
    Fabricate(:feedback) 
    
    @coach = Fabricate(:coach, name: 'coach_name', surname: 'coach_surname')
    @tutorial = Fabricate(:tutorial, title: 'tutorial title')
  end

  context 'Feedback form' do
    scenario "I can view a feedback form when token is valid" do
      visit feedback_path(valid_token) 

      expect(page).to have_select 'feedback_coach_id'
      expect(page).to have_select 'feedback_tutorial_id'
      expect(page).to have_field 'feedback_request'
      expect(page).to have_field 'feedback_suggestions'
      expect(page).to have_selector '//div.rating'
      expect(page).to have_selector '//input[type=submit]'
    end

    scenario 'I can select form coaches list in feedback form' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_coach_id', :with_options => [@coach.full_name])
    end

    scenario 'I can select form tutorials list in feedback form' do
      visit feedback_path(valid_token)

      expect(page).to have_select('feedback_tutorial_id', :with_options => [@tutorial.title])
    end
  end

  scenario "I get error message when invalid token given and link to homepage" do
    visit feedback_path(invalid_token)

    find_link('Return to homepage >>')[:href].should == root_path
    expect(page).to have_content('Sorry, feedback link seems to be invalid.')
  end

  context 'When form is submitted' do
    scenario 'I can see validation errors when invalid data given' do
      visit feedback_path(valid_token)
      click_button('Submit feedback')

      expect(page).to have_content("Coach can't be blank")
      expect(page).to have_content("Tutorial can't be blank")
    end

    scenario 'I can see success page with message and link to homepage when valid data' do
      visit feedback_path(valid_token)

      find(:xpath, "//input[@id='feedback_rating']").set "4"
      select(@coach.full_name, from: 'feedback_coach_id')
      select(@tutorial.title, from: 'feedback_tutorial_id')
      
      click_button('Submit feedback')

      current_path.should =~ /\/success/
      find_link('Return to homepage >>')[:href].should == root_path
      expect(page).to have_content(feedback_submited_message)
    end
  end

end
