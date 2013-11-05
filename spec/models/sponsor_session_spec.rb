require 'spec_helper'

describe SponsorSession do
  subject(:sponsor_session) { Fabricate(:hosted_session) }

  context 'when the session has more than one host' do
    let(:other_sponsor) { Fabricate(:sponsor) }

    let(:anohter_host_session) do
      Fabricate.build(:sponsor_session,
      sponsor: other_sponsor,
      sessions: sponsor_session.sessions,
      host: true)
    end

    it { anohter_host_session.should have(1).error_on(:host) }
  end
end