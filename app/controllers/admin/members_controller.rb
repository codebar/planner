class Admin::MembersController < Admin::ApplicationController

  def show
    @member = Member.includes(:member_notes).find(params[:id])
    @invitations = @member.session_invitations.accepted_or_attended.order_by_latest rescue nil
    @last_attendance = @invitations.first.workshop if @invitations.any?
    @member_note = MemberNote.new
  end

  def send_eligibility_email
    @member = Member.find(params[:member_id])
    @member.send_eligibility_email(current_user)
    redirect_to [:admin, @member], notice: "You have sent an eligibility confirmation request."
  end

  def send_attendance_email
    @member = Member.find(params[:member_id])
    @member.send_attendance_email(current_user)
    redirect_to [:admin, @member], notice: "You have sent an attendance warning."
  end
end
