RSpec.shared_examples 'viewing workshop actions' do
  scenario 'signing up or signing in' do
    expect(page).to have_content('Sign up')
    expect(page).to have_content('Log in')
  end
end
