class Admin::MeetingInvitationsController < Admin::ApplicationController
  before_action :set_invitation, only: [:update]

  def update
    status = params.permit(:attendance_status)[:attendance_status]
    attended = params.permit(:attended)[:attended]

    @invitation.update_attributes(attending: status, attended: attended)

    return redirect_to [:admin, @invitation.meeting],
                       notice: t('admin.messages.invitation.update_rsvp', name: @invitation.member.full_name)
  end

  def create
    member = Member.find(params[:meeting_invitations][:member])
    meeting = Meeting.find_by(slug: params[:meeting_invitations][:meeting_id])

    if MeetingInvitation.accepted.where(meeting: meeting, member: member).exists?
      return redirect_to [:admin, meeting],
                         notice: t('admin.messages.invitation.already_on_list', name: member.full_name)
    end

    invitation = meeting.invitations.find_or_create_by(member: member)
    invitation.assign_attributes(attending: true, role: 'Participant')

    if invitation.save
      MeetingInvitationMailer.approve_from_waitlist(meeting, member).deliver_now
      redirect_to [:admin, meeting], notice: t('admin.messages.invitation.rsvp_member', name: member.full_name)
    else
      redirect_to [:admin, meeting], notice: t('admin.messages.invitation.rsvp_error', name: member.full_name)
    end
  end

  private

  def set_invitation
    @invitation = MeetingInvitation.find_by(token: id)
  end

  def id
    params.permit(:id)[:id]
  end
end
