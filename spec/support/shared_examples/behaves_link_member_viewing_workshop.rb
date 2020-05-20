RSpec.shared_examples 'member viewing workshop' do |workshop_type, member_type, banned_member_type|
  context workshop_type do
    let(:workshop) { Fabricate(workshop_type) }

    scenario "allowed can manage" do
      member = Fabricate(member_type)
      login(member)
      visit workshop_path(workshop)

      expect(page).to have_button("Attend as a #{member_type.downcase}")
    end

    scenario 'banned cannot manage' do
      banned_member = Fabricate(banned_member_type)
      login(banned_member)
      visit workshop_path(workshop)

      expect(page).to_not have_button("Attend as a #{member_type.downcase}")
    end
  end
end
