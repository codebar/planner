require 'spec_helper'

describe SponsorSession do
  subject(:sponsor_session) { Fabricate(:hosted_session) }

  context 'when the session has more than one host' do
    let(:other_sponsor) { Fabricate(:sponsor) }

    let(:another_host_session) do
      Fabricate.build(:sponsor_session,
      sponsor: other_sponsor,
      sessions: sponsor_session.sessions,
      host: true)
    end

    it { another_host_session.should have(1).error_on(:host) }
  end

  context '#scopes' do
    let!(:hosted_session) { Fabricate(:hosted_session) }

    it '#hosts' do
      expect(SponsorSession.hosts.length).to eq(1)
    end

    describe '#for_session' do
      let(:session) { hosted_session.sessions }

      it { expect(SponsorSession.for_session(session.id).length).to eq(1) }
    end
  end
end