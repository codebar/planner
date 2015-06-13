class Admin::MembersController < Admin::ApplicationController

  def show
    @member = Member.includes(:member_notes).find(params[:id])
    @invitations = @member.session_invitations.attended.order_by_latest rescue nil
    @last_attendance = @invitations.first.sessions if @invitations.any?
    @member_note = MemberNote.new
  end

  def send_eligibility_email
    @member = Member.find(params[:member_id])
    @member.send_eligibility_email
    redirect_to [:admin, @member], notice: "You have sent an eligibility confirmation request."
  end
end
