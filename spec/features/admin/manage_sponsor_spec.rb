require 'spec_helper'

feature 'Managing sponsors' do
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
        fill_in 'Student Spots', with: 20

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
        fill_in 'Student Spots', with: 20

        click_on 'Create sponsor'

        expect(page).to have_content 'Namecan\'t be blank'
      end
    end
  end

  describe 'updating a sponsor' do
    context 'with valid input' do
      it 'updates the sponsor' do
        sponsor = Fabricate(:sponsor)

        visit edit_admin_sponsor_path(sponsor)

        fill_in 'Accessibility information', with: 'This venue is fully accessible to wheelchair users.'

        click_on 'Save changes'

        expect(page).to have_content 'This venue is fully accessible to wheelchair users.'
      end
    end
  end

  describe 'assigning a contact to a sponsor' do
    context 'assigning an existing member' do
      it 'updates the sponsor' do
        sponsor = Fabricate(:sponsor)
        member = Fabricate(:member)

        visit edit_admin_sponsor_path(sponsor)

        select member.name, from: 'sponsor_contact_ids'

        click_on 'Save changes'

        expect(page).to have_content member.name
      end
    end

    context 'assigning not a member' do
      it 'updates the sponsor' do
        sponsor = Fabricate(:sponsor)

        visit edit_admin_sponsor_path(sponsor)

        fill_in 'Email', with: 'test@email.com'
        fill_in 'Contact First Name', with: 'First name'
        fill_in 'Contact Surname', with: 'Surname'

        click_on 'Save changes'

        expect(page).to have_content 'First name Surname'
      end
    end
  end
end
