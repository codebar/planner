require 'spec_helper'

feature 'Managing subscriptionss' do
  let(:member) { Fabricate(:member) }
  let!(:group) { Fabricate(:group) }

  before do
    login(member)
  end

  context "a member can manage its subscriptions" do
    scenario "#subscribe" do
      visit subscriptions_path

      click_on "Subscribe"
      expect(page).to have_content("You have subscribed to #{group.chapter.city}'s #{group.name} group")
    end

    scenario "#unsubscribe" do
      subscription = Fabricate.create(:subscription, member: member, group: group)
      visit subscriptions_path

      click_on "Subscribed"
      expect(page).to have_content("You have unsubscribed from #{group.chapter.city}'s #{group.name} group")
    end
  end
end
