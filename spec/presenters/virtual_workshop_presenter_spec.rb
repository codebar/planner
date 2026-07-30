RSpec.describe VirtualWorkshopPresenter do
  def double_workshop(attending_coaches:, attending_students:)
    instance_double(Workshop, coach_spaces: 3, student_spaces: 5, chapter: chapter,
                              attending_coaches: instance_double(Array, length: attending_coaches),
                              attending_students: instance_double(Array, length: attending_students))
  end

  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 4) }
  let(:presenter) { described_class.new(workshop) }

  describe '#title' do
    it 'returns the title of a virtual workshop' do
      expect(presenter.title).to eq("Virtual workshop for #{chapter.name}")
    end
  end

  describe '#coach_spaces' do
    it 'returns the workshop\'s coach_spaces' do
      allow(workshop).to receive(:coach_spaces)

      presenter.coach_spaces

      expect(workshop).to have_received(:coach_spaces)
    end
  end

  describe '#student_spaces' do
    it 'returns the workshop\'s student spaces' do
      allow(workshop).to receive(:student_spaces)

      presenter.student_spaces

      expect(workshop).to have_received(:student_spaces)
    end
  end

  describe '#student_spaces?' do
    it 'checks if there are any more available student spots' do
      expect(presenter.student_spaces?).to be(true)
    end
  end

  describe '#coach_spaces?' do
    it 'checks if there are any more available coach spots' do
      expect(presenter.coach_spaces?).to be(false)
    end
  end

  describe '#spaces?' do
    context 'when there are more available spots' do
      let(:workshop) { double_workshop(attending_coaches: 2, attending_students: 5) }

      it 'returns true' do
        expect(presenter.spaces?).to be(true)
      end
    end

    context 'when there are no more available spots' do
      let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 5) }

      it 'returns false' do
        expect(presenter.spaces?).to be(false)
      end
    end
  end

  describe '#send_attending_email' do
    it 'enqueues an attending email to the invitation user' do
      invitation = instance_double(WorkshopInvitation, member: instance_double(Member))
      mailer_double = instance_double(ActionMailer::MessageDelivery)
      allow(VirtualWorkshopInvitationMailer)
        .to receive(:attending)
        .with(workshop, invitation.member, invitation, false)
        .and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_later)

      presenter.send_attending_email(invitation)

      expect(mailer_double).to have_received(:deliver_later)
    end

    it 'enqueues a waiting list email to the invitation user' do
      invitation = instance_double(WorkshopInvitation, member: instance_double(Member))
      mailer_double = instance_double(ActionMailer::MessageDelivery)
      allow(VirtualWorkshopInvitationMailer)
        .to receive(:attending)
        .with(workshop, invitation.member, invitation, true)
        .and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_later)

      presenter.send_attending_email(invitation, true)

      expect(mailer_double).to have_received(:deliver_later)
    end
  end
end
