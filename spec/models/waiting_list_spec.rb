require 'spec_helper'

RSpec.describe WaitingList, type: :model do
  let(:workshop) { Fabricate(:sessions)}

  context "scopes" do

    context "#by_workshop" do
      it "is empty when there are not invitations in the waiting list" do

        expect(WaitingList.by_workshop(workshop)).to eq([])
      end

      it "is returns the waiting list entries when there are any" do
        invitations = 2.times.map { Fabricate(:session_invitation, sessions: workshop) }
        invitations.each { |invitation| WaitingList.add(invitation) }

        expect(WaitingList.by_workshop(workshop).map(&:invitation)).to eq(invitations)
      end
    end

    context "#next_spot" do
      it "returns the next spot to be allocated" do
        invitation = Fabricate(:session_invitation, sessions: workshop)
        WaitingList.add(invitation)

        expect(WaitingList.next_spot(workshop, "Student").invitation).to eq(invitation)
      end
    end
  end

  context "#add" do
    it "is adds an invitation to the waiting list" do
      invitation = Fabricate(:session_invitation, sessions: workshop)
      WaitingList.add(invitation)

      expect(WaitingList.by_workshop(workshop).map(&:invitation)).to eq([invitation])
    end
  end
end
