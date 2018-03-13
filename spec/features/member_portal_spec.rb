require 'spec_helper'

feature 'Member portal' do
  subject { page }
  let(:member) { Fabricate(:member) }
  let!(:invitations) { 5.times.map { Fabricate(:attending_workshop_invitation, member: member) } }
  let!(:group) { Fabricate(:group) }

  context 'A signed in member' do
    before do
      login(member)
    end

    it 'can access the member dashboard' do
      visit dashboard_path

      expect(page).to have_content('Dashboard')
      expect(page).to have_content(member.full_name)
    end

    it 'can access and update their profile' do
      visit profile_path

      within '#member_profile' do
        click_on 'Update your details'
      end

      fill_in 'member_name', with: 'Jane'
      fill_in 'member_surname', with: 'Doe'
      click_button 'Save'

      expect(page).to have_content('Jane Doe')
    end

    it 'can subscribe to groups' do
      visit profile_path
      within '#member_profile' do
        click_on 'Manage subscriptions'
      end
      click_on 'Subscribe'

      expect(group.members).to include(member)
    end

    it 'can view the invitations they RSVPed to' do
      visit invitations_path

      expect(page).to have_content('Invitations')
      invitations.each do |invitation|
        expect(page).to have_content(invitation.parent.to_s)
        expect(page).to have_content(invitation.parent.chapter.name)
      end
    end
  end

  context 'A non authenticated visitor to the page' do
    it 'can not access the member portal' do
      visit root_path

      expect(page).to_not have_selector('#profile')
    end
  end
end
