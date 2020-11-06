require 'spec_helper'

RSpec.describe 'rake sponsors:members:migrate_to_contacts', type: :task do
  context 'creates Contact entries for Sponsor associated members' do
    it "preloads the Rails environment" do
      expect(task.prerequisites).to include "environment"
    end

    it 'executes gracefully' do
      expect { task.invoke }.to_not raise_error
    end

    context 'when a Sponsor has associated members' do
      let!(:sponsor) { Fabricate(:sponsor_with_member_contacts) }

      it 'creates associated Contact entries' do
        members = sponsor.members

        task.execute

        sponsor.reload

        members.each do |member|
          contact = sponsor.contacts.where(email: member.email).exists?
        end
      end

      it 'handles a failure when a Contact already exists for that member' do
        members = sponsor.members
        Fabricate(:contact, sponsor: sponsor, email: members.first.email)

        task.execute

        sponsor.reload

        members.each do |member|
          contact = sponsor.contacts.where(email: member.email).exists?
        end
      end

      it 'deletes the sponsor MemberContact association' do
        task.execute

        sponsor.reload

        expect(sponsor.member_contacts).to be_empty
      end
    end
  end
end
