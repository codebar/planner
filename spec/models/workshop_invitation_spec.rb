require 'spec_helper'

RSpec.describe WorkshopInvitation, type: :model do
  it_behaves_like InvitationConcerns, :workshop_invitation, :workshop

  context 'defaults' do
    it { is_expected.to have_attributes(attending: nil) }
    it { is_expected.to have_attributes(attended: nil) }
  end

  context 'validates' do
    it { is_expected.to validate_presence_of(:workshop) }
    it { is_expected.to validate_uniqueness_of(:member_id).scoped_to(:workshop_id, :role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(%w[Student Coach]) }

    it { is_expected.to validate_presence_of(:tutorial).on(:waitinglist) }
  end

  context 'scopes' do
    context '#attended' do
      it 'ignores when attended nil' do
        Fabricate(:workshop_invitation, attended: nil)

        expect(WorkshopInvitation.attended).to eq []
      end

      it 'ignores when attended false' do
        Fabricate(:workshop_invitation, attended: false)

        expect(WorkshopInvitation.attended).to eq []
      end

      it 'selects when attended true' do
        invitation = Fabricate(:workshop_invitation, attended: true)

        expect(WorkshopInvitation.attended).to include(invitation)
      end
    end

    context '#accepted_or_attended' do
      it 'ignores when attending nil and attended nil' do
        Fabricate(:workshop_invitation, attending: nil, attended: nil)

        expect(WorkshopInvitation.accepted_or_attended).to eq []
      end

      it 'ignores when attending false and attended false' do
        Fabricate(:workshop_invitation, attending: false, attended: false)

        expect(WorkshopInvitation.accepted_or_attended).to eq []
      end

      it 'selects when attending false and attended true' do
        invitation = Fabricate(:workshop_invitation, attending: false, attended: true)

        expect(WorkshopInvitation.accepted_or_attended).to include(invitation)
      end

      it 'selects when attending true and attended false' do
        invitation = Fabricate(:workshop_invitation, attending: true, attended: false)

        expect(WorkshopInvitation.accepted_or_attended).to include(invitation)
      end

      it 'selects when attending true and attended true' do
        invitation = Fabricate(:workshop_invitation, attending: true, attended: true)

        expect(WorkshopInvitation.accepted_or_attended).to include(invitation)
      end
    end

    it '#year' do
      new_workshop = Fabricate(:workshop, date_and_time: Time.zone.now)
      old_workshop = Fabricate(:workshop, date_and_time: Time.zone.now - 2.years)

      4.times { Fabricate(:attended_coach, workshop: new_workshop) }
      5.times { Fabricate(:attended_coach, workshop: old_workshop) }

      expect(WorkshopInvitation.year(Time.zone.now.year).count).to eq(4)
      expect(WorkshopInvitation.year((Time.zone.now - 2.years).year).count).to eq(5)
    end

    context '#not_reminded' do
      it 'includes invitations without reminders' do
        not_reminded = Fabricate(:student_workshop_invitation, reminded_at: nil)

        expect(WorkshopInvitation.not_reminded).to include(not_reminded)
      end

      it 'excludes invitations with reminders' do
        reminded = Fabricate(:workshop_invitation, reminded_at: 3.hours.ago)

        expect(WorkshopInvitation.not_reminded).not_to include(reminded)
      end
    end

    it '#on_waiting_list' do
      Fabricate.times(5, :workshop_invitation)
      waiting_list = Fabricate.times(2, :waitinglist_invitation)

      expect(WorkshopInvitation.on_waiting_list).to eq(waiting_list)
    end
  end

  context '#admin_set_attending' do
    it 'returns nil if has no recorded activities' do
      invitation = Fabricate(
        :workshop_invitation,
        attending: true,
        automated_rsvp: true,
        rsvp_time: Time.zone.now,
      )

      expect(invitation.admin_set_attending).to be_nil
    end

    it 'returns nil if last editor was the invited member' do
      waiting_list_invitation = Fabricate(:waitinglist_invitation)
      invited_user = waiting_list_invitation.member

      audit = Auditor::Audit.new(waiting_list_invitation, :attending, invited_user)
      audit.log do
        waiting_list_invitation.update(
          attending: true,
          automated_rsvp: true,
          rsvp_time: Time.zone.now,
        )
      end

      expect(waiting_list_invitation.admin_set_attending).to be_nil
    end

    it 'returns the name of the last editor if not the member invited' do
      waiting_list_invitation = Fabricate(:waitinglist_invitation)
      admin = Fabricate(:chapter_organiser)

      audit = Auditor::Audit.new(waiting_list_invitation, :attending, admin)
      audit.log do
        waiting_list_invitation.update(
          attending: true,
          automated_rsvp: true,
          rsvp_time: Time.zone.now,
        )
      end

      expect(waiting_list_invitation.admin_set_attending).to eq(admin.full_name)
    end
  end
end
