require 'spec_helper'

RSpec.describe WorkshopSponsor, type: :model  do
  let!(:workshop) { Fabricate(:workshop) }

  context '#scopes' do
    it '#hosts' do
      expect(WorkshopSponsor.hosts.length).to eq(1)
    end

    it '#for_workshop' do
      expect(WorkshopSponsor.for_workshop(workshop).length).to eq(1)
    end
  end
end
