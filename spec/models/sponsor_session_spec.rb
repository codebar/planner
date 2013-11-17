require 'spec_helper'

describe SponsorSession do
  let!(:session) { Fabricate(:sessions) }

  context 'when the session has more than one host' do
    let(:other_sponsor) { Fabricate(:sponsor) }

    let(:another_host_session) do
      Fabricate.build(:sponsor_session,
      sponsor: other_sponsor,
      sessions: session,
      host: true)
    end

    it { another_host_session.should have(1).error_on(:host) }
  end

  context '#scopes' do

    it '#hosts' do
      expect(SponsorSession.hosts.length).to eq(1)
    end

    it '#for_session' do
      expect(SponsorSession.for_session(session.id).length).to eq(1)
    end
  end
end