require 'spec_helper'

feature 'member portal' do
  subject { page }
  let(:member) { Fabricate(:member) }

  context "signed in" do
    it "should be able to access the portal menu" do
      login(member)
      visit root_path

      expect(page).to have_selector("#profile")
    end
  end

  context "not signed in" do
    it "not should be able to access the portal menu" do
      visit root_path

      expect(page).to_not have_selector("#profile")
    end
  end
end
