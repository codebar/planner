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

    context 'when workshop.student_spaces is 0 but sponsor has capacity (production data scenario)' do
      let(:sponsor) { Fabricate(:sponsor, seats: 20, number_of_coaches: 10) }
      let(:workshop_with_zero_spaces) do
        Fabricate(:workshop_no_sponsor, student_spaces: 0, coach_spaces: 0).tap do |ws|
          Fabricate(:workshop_sponsor, workshop: ws, sponsor: sponsor, host: true)
        end
      end
      let(:presenter_zero_spaces) { WorkshopPresenter.new(workshop_with_zero_spaces) }

      before do
        # Create 1 attending student
        member = Fabricate(:member)
        Fabricate(:workshop_invitation, workshop: workshop_with_zero_spaces, member: member, role: 'Student', attending: true)
      end

      it 'returns true because capacity comes from sponsor, not workshop.student_spaces' do
        expect(workshop_with_zero_spaces.attending_students.count).to eq(1)
        expect(workshop_with_zero_spaces.student_spaces).to eq(0)
        expect(presenter_zero_spaces.student_spaces).to eq(20), 'Capacity should come from sponsor'
        expect(presenter_zero_spaces.event_student_spaces?).to eq(true),
          "Expected event_student_spaces? to be true when sponsor has capacity (1/20), but got false"
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

    context 'when workshop.coach_spaces is 0 but sponsor has capacity (production data scenario)' do
      let(:sponsor) { Fabricate(:sponsor, seats: 20, number_of_coaches: 10) }
      let(:workshop_with_zero_spaces) do
        Fabricate(:workshop_no_sponsor, student_spaces: 0, coach_spaces: 0).tap do |ws|
          Fabricate(:workshop_sponsor, workshop: ws, sponsor: sponsor, host: true)
        end
      end
      let(:presenter_zero_spaces) { WorkshopPresenter.new(workshop_with_zero_spaces) }

      before do
        # Create 1 attending coach
        member = Fabricate(:member)
        Fabricate(:workshop_invitation, workshop: workshop_with_zero_spaces, member: member, role: 'Coach', attending: true)
      end

      it 'returns true because capacity comes from sponsor, not workshop.coach_spaces' do
        expect(workshop_with_zero_spaces.attending_coaches.count).to eq(1)
        expect(workshop_with_zero_spaces.coach_spaces).to eq(0)
        expect(presenter_zero_spaces.coach_spaces).to eq(10), 'Capacity should come from sponsor'
        expect(presenter_zero_spaces.event_coach_spaces?).to eq(true),
          "Expected event_coach_spaces? to be true when sponsor has capacity (1/10), but got false"
      end
    end
  end
end
