require 'spec_helper'

RSpec.describe VirtualWorkshopPresenter do
  def double_workshop(attending_coaches:, attending_students:)
    double(:workshop, coach_spaces: 3, student_spaces: 5, chapter: chapter,
                      attending_coaches: double(:attending_coaches, length: attending_coaches),
                      attending_students: double(:attending_students, length: attending_students))
  end

  let(:chapter) { Fabricate(:chapter) }
  let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 4) }
  let(:presenter) { VirtualWorkshopPresenter.new(workshop) }

  context '#title' do
    it 'returns the title of a virtual workshop' do
      expect(presenter.title).to eq("Virtual workshop for #{chapter.name}")
    end
  end

  context '#coach_spaces' do
    it 'returns the workshop\'s coach_spaces' do
      expect(workshop).to receive(:coach_spaces)

      presenter.coach_spaces
    end
  end

  context '#student_spaces' do
    it 'returns the workshop\'s student spaces' do
      expect(workshop).to receive(:student_spaces)

      presenter.student_spaces
    end
  end

  context '#student_spaces?' do
    it 'checks if there are any more available student spots' do
      expect(presenter.student_spaces?).to eq(true)
    end
  end

  context '#coach_spaces?' do
    it 'checks if there are any more available coach spots' do
      expect(presenter.coach_spaces?).to eq(false)
    end
  end

  context '#spaces?' do
    context 'when there are more available spots' do
      let(:workshop) { double_workshop(attending_coaches: 2, attending_students: 5) }

      it 'it returns true' do
        expect(presenter.spaces?).to eq(true)
      end
    end

    context 'when there are no more available spots' do
      let(:workshop) { double_workshop(attending_coaches: 3, attending_students: 5) }

      it 'it returns false' do
        expect(presenter.spaces?).to eq(false)
      end
    end
  end

  context '#send_attending_email' do
    it 'send an attending email to the invitation user' do
      workshop_invitation_mailer = double(:workshop_invitation_mailed, deliver_now: true)
      invitation = double(:invitation, member: double(:member))
      expect(VirtualWorkshopInvitationMailer)
        .to receive(:attending)
        .with(workshop, invitation.member, invitation, false)
        .and_return(workshop_invitation_mailer)

      presenter.send_attending_email(invitation)
    end

    it 'send a waiting list email to the invitation user' do
      workshop_invitation_mailer = double(:workshop_invitation_mailed, deliver_now: true)
      invitation = double(:invitation, member: double(:member))
      expect(VirtualWorkshopInvitationMailer)
        .to receive(:attending)
        .with(workshop, invitation.member, invitation, true)
        .and_return(workshop_invitation_mailer)

      presenter.send_attending_email(invitation, true)
    end
  end
end
