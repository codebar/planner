RSpec.shared_examples 'viewing workshop actions' do
  scenario 'signing up or signing in' do
    expect(page).to have_text('Join our community')
    expect(page).to have_text('Log in')
  end
end
