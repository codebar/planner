require 'spec_helper'

RSpec.feature 'Managing sponsors', type: :feature do
  let(:member) { Fabricate(:member) }
  let!(:chapter) { Fabricate(:chapter) }

  before do
    login_as_admin(member)
    member.add_role(:organiser, Chapter)
  end

  describe 'creating a new sponsor' do
    context 'with valid input' do
      it 'creates a sponsor' do
        visit new_admin_sponsor_path

        fill_in 'sponsor_name', with: 'Sponsor name'
        fill_in 'Website', with: 'https://www.sponsorname.com/'
        attach_file('Avatar', Rails.root + 'spec/support/codebar-logo.png')
        fill_in 'Student spots', with: 20
        select "Bronze", from: "Level"

        click_on 'Create sponsor'

        expect(page).to have_content 'Sponsor Sponsor name created'
      end
    end

    context 'with invalid input' do
      it 'shows an error message' do
        visit new_admin_sponsor_path

        fill_in 'sponsor_name', with: ''
        fill_in 'Website', with: 'https://www.sponsorname.com/'
        attach_file('Avatar', Rails.root + 'spec/support/codebar-logo.png')
        fill_in 'Student spots', with: 20

        click_on 'Create sponsor'

        expect(page).to have_content 'Namecan\'t be blank'
      end
    end

    context 'with invalid input' do
      it 'renders new and shows create button' do
        visit new_admin_sponsor_path

        fill_in 'sponsor_name', with: ''
        fill_in 'Website', with: 'https://www.sponsorname.com/'
        attach_file('Avatar', Rails.root + 'spec/support/codebar-logo.png')
        fill_in 'Student spots', with: 20

        click_on 'Create sponsor'

        expect(page).to have_button('Create sponsor')
      end
    end
  end

  describe 'updating a sponsor' do
    context 'with valid input' do
      it 'updates the sponsor' do
        sponsor = Fabricate(:sponsor)

        visit edit_admin_sponsor_path(sponsor)

        fill_in 'Accessibility information', with: 'This venue is fully accessible to wheelchair users.'
        fill_in 'Directions', with: 'Office is located on the third floor.'

        click_on 'Save changes'

        expect(page).to have_content 'This venue is fully accessible to wheelchair users.'
      end
    end
  end

  describe 'adding contact information to a sponsor' do
    let(:sponsor) { Fabricate(:sponsor) }

    context 'assigning a member' do
      it 'updates the sponsor' do
        member = Fabricate(:member)

        visit edit_admin_sponsor_path(sponsor)

        select member.name, from: 'sponsor_member_ids'
        click_on 'Save changes'

        expect(page).to have_content member.name
      end
    end

    context 'adding contact details' do
      it 'adds a new contact entry' do
        visit edit_admin_sponsor_path(sponsor)

        within '#contacts' do
          fill_in 'Name', with: 'Jane'
          fill_in 'Surname', with: 'Doe'
          fill_in 'Email', with: 'jane@codebar.io'
        end

        click_on 'Save changes'

        expect(page).to have_content 'Jane Doe (jane@codebar.io)'
      end
    end
  end
end
