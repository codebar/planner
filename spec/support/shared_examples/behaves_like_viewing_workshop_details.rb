RSpec.shared_examples 'viewing workshop details' do
  scenario 'sponsors' do
    within '#sponsors' do
      workshop.sponsors.each do |sponsor|
        expect(page).to have_css("img[src=\"#{sponsor.avatar}\"]")
      end
    end
  end

  scenario 'organisers' do
    within '#organisers' do
      expect(page).to have_content('Organisers')

      workshop.organisers.each do |organiser|
        expect(page).to have_content(organiser.full_name)
      end
    end
  end
end
