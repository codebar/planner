require 'rails_helper'

RSpec.describe 'WorkshopPresenter capacity checks', type: :model do
  describe '#event_student_spaces?' do
    let(:workshop) { Fabricate(:workshop, student_count: 2, coach_count: 2) }
    let(:presenter) { WorkshopPresenter.new(workshop) }

    context 'when workshop is at capacity' do
      before do
        # Create 2 attending students (at capacity)
        2.times do
          member = Fabricate(:member)
          Fabricate(:workshop_invitation, workshop: workshop, member: member, role: 'Student', attending: true)
        end
      end

      it 'returns false when no spaces are available' do
        expect(workshop.attending_students.count).to eq(2)
        expect(workshop.student_spaces).to eq(2)
        expect(presenter.event_student_spaces?).to eq(false), 
          "Expected event_student_spaces? to be false when at capacity (2/2), but got true"
      end
    end

    context 'when workshop has available spaces' do
      before do
        # Create 1 attending student (below capacity)
        member = Fabricate(:member)
        Fabricate(:workshop_invitation, workshop: workshop, member: member, role: 'Student', attending: true)
      end

      it 'returns true when spaces are available' do
        expect(workshop.attending_students.count).to eq(1)
        expect(workshop.student_spaces).to eq(2)
        expect(presenter.event_student_spaces?).to eq(true),
          "Expected event_student_spaces? to be true when spaces available (1/2), but got false"
      end
    end
  end

  describe '#event_coach_spaces?' do
    let(:workshop) { Fabricate(:workshop, student_count: 2, coach_count: 2) }
    let(:presenter) { WorkshopPresenter.new(workshop) }

    context 'when workshop is at coach capacity' do
      before do
        # Create 2 attending coaches (at capacity)
        2.times do
          member = Fabricate(:member)
          Fabricate(:workshop_invitation, workshop: workshop, member: member, role: 'Coach', attending: true)
        end
      end

      it 'returns false when no coach spaces are available' do
        expect(workshop.attending_coaches.count).to eq(2)
        expect(presenter.event_coach_spaces?).to eq(false),
          "Expected event_coach_spaces? to be false when at capacity (2/2), but got true"
      end
    end

    context 'when workshop has available coach spaces' do
      before do
        # Create 1 attending coach (below capacity)
        member = Fabricate(:member)
        Fabricate(:workshop_invitation, workshop: workshop, member: member, role: 'Coach', attending: true)
      end

      it 'returns true when coach spaces are available' do
        expect(workshop.attending_coaches.count).to eq(1)
        expect(presenter.event_coach_spaces?).to eq(true),
          "Expected event_coach_spaces? to be true when spaces available (1/2), but got false"
      end
    end
  end
end
