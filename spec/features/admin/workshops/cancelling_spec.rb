require 'spec_helper'

module Admin::Workshop
  RSpec.feature 'Cancelling', type: :feature do
    let(:member) { Fabricate(:member) }
    let!(:chapter) { Fabricate(:chapter) }

    before do
      login_as_admin(member)
      member.add_role(:organiser, Chapter)
    end

    context "#create" do
      it "can cancel a workshop", js: true do
        workshop = Fabricate(:workshop)
        visit admin_workshop_path(workshop)

        click_link 'Cancel'

        expect(page).to have_current_path admin_workshop_path(workshop)
        expect(page).to have_content('This event has been cancelled')

        visit workshop_path(workshop)
        expect(page).to have_content('This event has been cancelled')
      end
    end
  end
end
