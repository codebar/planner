RSpec.shared_examples 'Invitable' do |invitation_type, invitable_type|
  let(:invitable) { Fabricate(invitable_type) }

  context '#attendances' do
    it 'permits accepted' do
      invitation = Fabricate(invitation_type,
                             invitable_type => invitable,
                             attending: true)

      expect(invitable.reload.attendances).to include(invitation)
    end

    it 'rejects non-accepted' do
      invitation = Fabricate(invitation_type,
                             invitable_type => invitable,
                             attending: false)

      expect(invitable.reload.attendances).to_not include(invitation)
    end

    it 'rejects banned accepted' do
      invitation = Fabricate(invitation_type,
                             member: Fabricate(:banned_member),
                             invitable_type => invitable,
                             attending: true)

      expect(invitable.reload.attendances).to_not include(invitation)
    end
  end

  context '#attending_students' do
    it 'accepts attending students' do
      invitation_to_student = Fabricate(invitation_type,
                                        role: 'Student',
                                        invitable_type => invitable,
                                        attending: true)

      expect(invitable.reload.attending_students).to include(invitation_to_student)
    end

    it 'rejects non-attending students' do
      invitation_to_student = Fabricate(invitation_type,
                                        role: 'Student',
                                        invitable_type => invitable,
                                        attending: false)

      expect(invitable.reload.attending_students).to_not include(invitation_to_student)
    end

    it 'rejects banned attending students' do
      invitation_to_banned_student = Fabricate(invitation_type,
                                        member: Fabricate(:banned_member),
                                        role: 'Student',
                                        invitable_type => invitable,
                                        attending: true)

                                        # byebug
      expect(invitable.reload.attending_students).to_not include(invitation_to_banned_student)
    end
  end

  context '#attending_coaches' do
    it 'accepts attending coaches' do
      invitation_to_coach = Fabricate(invitation_type,
                                      role: 'Coach',
                                      invitable_type => invitable,
                                      attending: true)

      expect(invitable.reload.attending_coaches).to include(invitation_to_coach)
    end

    it 'rejects non-attending coaches' do
      invitation_to_coach = Fabricate(invitation_type,
                                      role: 'Coach',
                                      invitable_type => invitable,
                                      attending: false)

      expect(invitable.reload.attending_coaches).to_not include(invitation_to_coach)
    end

    it 'rejects banned attending coaches' do
      invitation_to_banned_student = Fabricate(invitation_type,
                                        member: Fabricate(:banned_member),
                                        role: 'Student',
                                        invitable_type => invitable,
                                        attending: true)

      expect(invitable.reload.attending_students).to_not include(invitation_to_banned_student)
    end
  end
end
