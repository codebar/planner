require 'rails_helper'

RSpec.describe 'AuthServices callback' do
  it 'reuses the winner when a concurrent callback just created the same auth service' do
    winner = Fabricate(:member, email: 'winner@example.com')
    winner_service = Fabricate(:auth_service, member: winner,
                                              provider: 'github',
                                              uid: 'race-uid-123')

    mock_auth_hash(provider: 'github', uid: 'race-uid-123',
                   email: 'loser@example.com')

    # Simulate the losing callback: it read the DB *before* the winner committed,
    # so its initial find_by saw nothing; the insert then collides and the rescue
    # re-finds the winner via find_by!.
    allow(AuthService).to receive_messages(find_by: nil, find_by!: winner_service)

    expect { post '/auth/github/callback' }.not_to raise_error

    # The winner is a complete member, so the losing callback must not bounce
    # them back to the details page — they go to the dashboard instead.
    expect(response).to redirect_to(dashboard_path)
    expect(session[:member_id]).to eq(winner.id)
    expect(session[:service_id]).to eq(winner_service.id)
    expect(winner.reload.active?).to be(true)
  end

  it 'sends a complete member who links a second provider to the dashboard, not details' do
    complete = Fabricate(:member, email: 'existing@example.com')
    mock_auth_hash(provider: 'github', uid: 'second-uid',
                   email: 'existing@example.com')

    post '/auth/github/callback'

    expect(response).to redirect_to(dashboard_path)
    expect(session[:member_id]).to eq(complete.id)
  end

  it 'sends a complete member who links a second provider to a stored referer' do
    complete = Fabricate(:member, email: 'referer@example.com')
    mock_auth_hash(provider: 'github', uid: 'second-uid-referer',
                   email: 'referer@example.com')

    # AuthServicesController#new (GET /login) stores a workshop/event/meeting
    # referer in the session; a complete member then follows it instead of
    # being bounced to the details page.
    get '/login', headers: { 'HTTP_REFERER' => '/workshops/1' }
    post '/auth/github/callback'

    expect(response).to redirect_to('/workshops/1')
    expect(session[:member_id]).to eq(complete.id)
  end

  it 'sends a brand-new member to complete their profile details' do
    mock_auth_hash(provider: 'github', uid: 'new-uid', email: 'new@example.com')

    post '/auth/github/callback'

    expect(response).to redirect_to(edit_member_details_path)
  end
end
