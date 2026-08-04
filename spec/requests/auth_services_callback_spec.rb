require 'rails_helper'

RSpec.describe 'AuthServices callback', type: :request do
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

    expect(response).to redirect_to(edit_member_details_path)
    expect(session[:member_id]).to eq(winner.id)
    expect(session[:service_id]).to eq(winner_service.id)
    # the losing callback must not flip the winner's can_log_in flag back
    expect(winner.reload.can_log_in).to be(false)
  end
end
