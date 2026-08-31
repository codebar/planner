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
    expect(session[:new_member]).to be(true)
  end

  it 'does not mark an existing incomplete member as a new signup when they return to complete their profile' do
    returning = Fabricate(:member, name: nil, surname: nil, about_you: nil,
                                   email: 'returning@example.com')
    returning.auth_services.delete_all
    svc = Fabricate(:auth_service, member: returning,
                                   provider: 'github', uid: 'returning-github-uid')
    mock_auth_hash(provider: 'github', uid: svc.uid,
                   email: 'returning@example.com', name: nil)

    post '/auth/github/callback'

    expect(response).to redirect_to(edit_member_details_path)
    expect(session[:new_member]).to be_nil
  end

  it 'links a codebar callback to an existing member via legacy github id when emails differ' do
    original = Fabricate(:member, email: 'original@example.com')
    Fabricate(:auth_service, member: original, provider: 'github', uid: '12345')

    mock_auth_hash(provider: 'codebar', uid: 'different@example.com',
                   email: 'different@example.com', github_id: '12345')

    expect { post '/auth/codebar/callback' }
      .to change { original.reload.auth_services.where(provider: 'codebar').count }.by(1)

    expect(response).to redirect_to(dashboard_path)
    expect(session[:member_id]).to eq(original.id)
    expect(Member.where(email: 'different@example.com').count).to eq(0)
  end

  it 'creates a new member when the codebar callback has no matching github id or email' do
    Fabricate(:member, email: 'existing@example.com')
    Fabricate(:auth_service, provider: 'github', uid: '99999')

    mock_auth_hash(provider: 'codebar', uid: 'brandnew@example.com',
                   email: 'brandnew@example.com', github_id: '11111')

    expect { post '/auth/codebar/callback' }.to change(Member, :count).by(1)

    expect(response).to redirect_to(edit_member_details_path)
  end

  it 'prefers github_id over email when they resolve to different members' do
    member_a = Fabricate(:member, email: 'a@example.com')
    Fabricate(:auth_service, member: member_a, provider: 'github', uid: '12345')
    member_b = Fabricate(:member, email: 'b@example.com')
    member_b_codebar_count = member_b.auth_services.where(provider: 'codebar').count

    mock_auth_hash(provider: 'codebar', uid: 'b@example.com',
                   email: 'b@example.com', github_id: '12345')

    expect { post '/auth/codebar/callback' }
      .to change { member_a.reload.auth_services.where(provider: 'codebar').count }.by(1)

    expect(session[:member_id]).to eq(member_a.id)
    expect(member_b.reload.auth_services.where(provider: 'codebar').count).to eq(member_b_codebar_count)
    expect(Member.count).to eq(2)
  end

  it 'falls back to email matching when the codebar callback has no github_id' do
    existing = Fabricate(:member, email: 'fallback@example.com')

    mock_auth_hash(provider: 'codebar', uid: 'fallback@example.com',
                   email: 'fallback@example.com')

    post '/auth/codebar/callback'

    expect(session[:member_id]).to eq(existing.id)
    expect(response).to redirect_to(dashboard_path)
  end
end
