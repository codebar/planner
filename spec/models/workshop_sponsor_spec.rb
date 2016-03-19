require 'spec_helper'

describe WorkshopSponsor do
  let!(:workshop) { Fabricate(:workshop) }

  context '#scopes' do

    it '#hosts' do
      expect(WorkshopSponsor.hosts.length).to eq(1)
    end

    it '#for_session' do
      expect(WorkshopSponsor.for_session(workshop).length).to eq(1)
    end
  end
end
