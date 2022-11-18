require 'spec_helper'

RSpec.feature 'Managing testimonials', type: :feature do
  let(:member) { Fabricate(:member) }

  scenario 'non admin cannot manage testimonials' do
    login(member)

    visit admin_testimonials_path
    expect(current_url).to eq(root_url)
    expect(page).to have_content("You can't be here")
  end

  context 'an admin member' do
    before do
      login_as_admin(member)
    end

    scenario 'can view a list of testimonials' do
      testimonial = Fabricate(:testimonial)

      visit admin_testimonials_path

      expect(page).to have_content('Testimonials')
      expect(page).to have_content(testimonial.text)
    end
  end
end