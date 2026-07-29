RSpec.feature 'Internationalization', type: :feature do
  after do
    I18n.locale = :en
  end

  context 'when a visitor to the website' do
    context 'when viewing the website in English' do
      scenario 'by default' do
        visit code_of_conduct_path

        expect(page).to have_text('Our events are dedicated to providing a harassment-free experience for everyone')
      end
    end

    context 'when a user can configure another language by setting `locale=en|gr|de`' do
      scenario 'can view the code of conduct in French' do
        visit root_path(locale: 'fr')
        visit code_of_conduct_path

        expect(page).to have_text('Nous nous engageons à fournir une expérience bienveillante et dépourvue de harcèlement pour tout le monde')
      end
    end

    context 'when a user cannot configure a non existing language' do
      scenario 'by setting `locale=it`' do
        visit code_of_conduct_path(locale: 'it')

        expect(page).to have_text('Our events are dedicated to providing a harassment-free experience for everyone')
      end
    end
  end
end
