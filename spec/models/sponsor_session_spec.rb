require 'spec_helper'

describe SponsorSession do
  let!(:session) { Fabricate(:sessions) }

  context '#scopes' do

    it '#hosts' do
      expect(SponsorSession.hosts.length).to eq(1)
    end

    it '#for_session' do
      expect(SponsorSession.for_session(session.id).length).to eq(1)
    end
  end
end
