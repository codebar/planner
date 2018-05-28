require 'spec_helper'

feature 'Internationalization' do
  context 'a visitor to the website' do
    context 'views the website in English' do
      scenario 'by default' do
        visit code_of_conduct_path

        expect(page).to have_content('Our events are dedicated to providing a harassment-free experience for everyone')
      end
    end

    context 'can configure another language by setting `locale=en|gr|de`' do
      scenario 'can view the code of conduct in French' do
        visit root_path(locale: 'fr')
        visit code_of_conduct_path

        expect(page).to have_content('Nous nous engageons à fournir une expérience bienveillante et dépourvue de harcèlement pour tout le monde')
      end
    end

    context 'can not configure a non existing language' do
      scenario 'by setting `locale=it`' do
        visit code_of_conduct_path(locale: 'it')

        expect(page).to have_content('Our events are dedicated to providing a harassment-free experience for everyone')
      end
    end
  end
end
