require 'spec_helper'

feature 'admin portal' do

  scenario 'non admin cannot access the admin portal' do
    member = Fabricate(:member)
    login(member)
    visit admin_root_path

    current_url.should eq root_url
  end

  context "an admin user" do
    let(:member) { Fabricate(:admin) }

    before do
      login(member)
    end

    scenario 'can access the admin portal' do
      visit admin_root_path

      current_url.should eq admin_root_url
    end
  end
end
