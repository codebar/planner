require 'spec_helper'

describe Invitation do
  context 'validations' do
    subject { Invitation.new }

  it '#event' do
    should have(1).error_on(:event)
  end

  it '#role' do
    should have(1).error_on(:role)
  end
  end

  context '#student_spaces?' do
    it 'checks if there are any available spaces for students at the event' do
      student_invitation = Fabricate(:invitation)

      expect(student_invitation.student_spaces?).to eq(true)
    end
  end

  context '#coach_spaces?' do
    it 'checks if there are any available spaces for coaches at the event' do
      coach_invitation = Fabricate(:coach_invitation)

      expect(coach_invitation.coach_spaces?).to eq(true)
    end
  end
end
