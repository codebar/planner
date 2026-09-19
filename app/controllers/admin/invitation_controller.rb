class Admin::InvitationController < Admin::ApplicationController
  include Admin::WorkshopConcerns

  # event invitations

  # rubocop:disable Metrics/AbcSize
  def update
    invitation = Invitation.find_by(token: params[:invitation][:id])
    invitation.update(attending: true, verified: true, verified_by: current_user, source: Invitation::SOURCE_ADMIN)
    MemberActivityRecorder.record(actor: current_user, key: 'invitation.verified',
                                  trackable: invitation, recipient: invitation.member)

    EventInvitationMailer.attending(invitation.event, invitation.member, invitation).deliver_now

    redirect_back(
      fallback_location: root_path,
      notice: "You have verified #{invitation.member.full_name}'s spot at the event!"
    )
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def verify
    invitation = Invitation.find_by(token: params[:invitation_id])
    invitation.update(verified: true, verified_by_id: current_user.id, source: Invitation::SOURCE_ADMIN)
    MemberActivityRecorder.record(actor: current_user, key: 'invitation.verified',
                                  trackable: invitation, recipient: invitation.member)

    EventInvitationMailer.attending(invitation.event, invitation.member, invitation).deliver_now

    redirect_back(
      fallback_location: root_path,
      notice: "You have verified #{invitation.member.full_name}'s spot at the event!"
    )
  end
  # rubocop:enable Metrics/AbcSize

  def cancel
    invitation = Invitation.find_by(token: params[:invitation_id])
    invitation.update(attending: false)

    redirect_back(
      fallback_location: root_path,
      notice: "You have cancelled #{invitation.member.full_name}'s attendance."
    )
  end
end
