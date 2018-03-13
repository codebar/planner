require 'spec_helper'

describe 'feedback:request' do
  include_context 'rake'

  its(:prerequisites) { should include('environment') }

  context 'when most recent workshop has attendances' do
    let(:group) { Fabricate(:students) }
    let(:workshop) { Fabricate(:workshop, date_and_time: 1.day.ago, chapter: group.chapter) }
    let(:student) { Fabricate(:member) }
    let!(:subscription) { Fabricate(:subscription, group: group, member: student) }

    before do
      allow(STDOUT).to receive(:puts)
      student.workshop_invitations << Fabricate(:attending_workshop_invitation, member: student, workshop: workshop)
    end

    it 'should gracefully run' do
      expect { subject.invoke }.to_not raise_error
    end

    it 'generates a FeedbackRequest' do
      expect(FeedbackRequest).to receive(:create).with(member: student, workshop: workshop, submited: false)

      subject.invoke
    end
  end
end
