class Admin::MeetingInvitationsController < Admin::ApplicationController
  before_action :set_invitation, only: [:update]

  def update
    status = params[:attendance_status]
    attended = params[:attended]

    @invitation.update_attributes(attending: status, attended: attended)

    redirect_to [:admin, @invitation.meeting]
  end

  def create
    member = Member.find(params[:meeting_invitations][:member])
    meeting = Meeting.find_by(slug: params[:meeting_invitations][:meeting_id])

    if meeting.invitations.accepted.map(&:member_id).include?(member.id)
      return redirect_to [:admin, meeting], notice: "#{member.full_name} is already on the list!"
    end

    invite = meeting.invitations.create(member: member, attending: true, role: 'Participant')

    if invite.save
      redirect_to [:admin, meeting], notice: "#{member.full_name} has been successfully added and notified via email."
      MeetingInvitationMailer.approve_from_waitlist(meeting, member, invite).deliver_now
    else
      redirect_to [:admin, meeting], notice: "Something went wrong, #{member.full_name} has not been added."
    end
  end

  private

  def set_invitation
    @invitation = MeetingInvitation.find_by(token: params[:id])
  end
end
