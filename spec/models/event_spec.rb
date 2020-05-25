require 'spec_helper'

RSpec.describe Event, type: :model  do
  subject(:event) { Fabricate(:event) }
  include_examples "Invitable", :invitation, :event

  context 'validates' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_presence_of(:info) }
    it { is_expected.to validate_presence_of(:schedule) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_numericality_of(:coach_spaces) }
    it { is_expected.to validate_numericality_of(:student_spaces) }

    context "#invitablility" do
      it 'does not validate if invitable false' do
        event.invitable = false
        event.coach_spaces = nil
        event.student_spaces = nil

        event.valid?

        expect(event.errors[:coach_spaces]).to_not include('must be set')
        expect(event.errors[:student_spaces]).to_not include('must be set')
      end

      context 'with invitable true' do
        it 'validates coach_spaces' do
          event.invitable = true
          event.coach_spaces = nil

          event.valid?

          expect(event.errors[:coach_spaces]).to include('must be set')
        end

        it 'validates student_spaces' do
          event.invitable = true
          event.student_spaces = nil

          event.valid?

          expect(event.errors[:student_spaces]).to include('must be set')
        end

        it 'it does not validates invitable if student spaces and coach spaces present' do
          event.invitable = true
          event.coach_spaces = 1
          event.student_spaces = 1

          event.valid?

          expect(event.errors[:invitable])
                      .to_not include('Fill in all invitations details to make the event invitable')
        end

        it 'it validates invitable if student spaces or coach spaces missing' do
          event.invitable = true
          event.coach_spaces = 1
          event.student_spaces = nil

          event.valid?

          expect(event.errors[:invitable])
                      .to include('Fill in all invitations details to make the event invitable')
        end

        it 'validates invitable if both student spaces and coach spaces missing' do
          event.invitable = true
          event.coach_spaces = nil
          event.student_spaces = nil

          event.valid?

          expect(event.errors[:invitable])
                      .to include('Fill in all invitations details to make the event invitable')
        end
      end
    end
  end

  context '#verified_students' do
    it 'returns all students who have verified their attendance' do
      event = Fabricate(:event)
      2.times.map { Fabricate(:invitation, event: event, attending: true) }
      3.times.map { Fabricate(:invitation, event: event, attending: true, verified: true) }

      expect(event.verified_students.count).to eq(3)
    end
  end
end
