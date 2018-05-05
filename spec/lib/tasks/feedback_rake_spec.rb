require 'spec_helper'

describe 'feedback:request' do
  include_context 'rake'

  its(:prerequisites) { should include('environment') }

  context 'when most recent workshop has attendances' do
    let(:group) { Fabricate(:students) }
    let(:workshop) { Fabricate(:workshop, date_and_time: 23.hours.ago, chapter: group.chapter) }
    let(:student) { Fabricate(:member) }
    let!(:subscription) { Fabricate(:subscription, group: group, member: student) }

    it 'should gracefully run' do
      expect { subject.invoke }.to_not raise_error
    end

    it 'generates a FeedbackRequest' do
      Fabricate(:attending_workshop_invitation, role: 'Student', member: student, workshop: workshop)

      expect(Workshop).to receive(:completed_since_yesterday).and_return([workshop])
      expect(FeedbackRequest).to receive(:create).with(member: student, workshop: workshop, submited: false)

      subject.invoke
    end

    it 'only generates a FeedbackRequest for workshops that took place in the last 24 hours' do
      past_workshops = [ Fabricate(:workshop, date_and_time: 3.days.ago),
                         Fabricate(:workshop, date_and_time: 24.hours.ago)]

      yesterdays_workshops = [ Fabricate(:workshop, date_and_time: 1.hours.ago),
                               Fabricate(:workshop, date_and_time: 20.hours.ago),
                               Fabricate(:workshop, date_and_time: (23.hours + 59.minutes).ago)]

      past_workshops.each { |w| Fabricate(:attending_workshop_invitation, member: student, workshop: w) }
      yesterdays_workshops.each { |w| Fabricate(:attending_workshop_invitation, member: student, workshop: w) }

      subject.invoke

      past_workshops.each do |workshop|
        expect(FeedbackRequest.where(member: student, workshop: workshop, submited: false).exists?).to eq(false)
      end

      yesterdays_workshops.each do |workshop|
        expect(FeedbackRequest.where(member: student, workshop: workshop, submited: false).exists?).to eq(true)
      end

    end
  end
end
