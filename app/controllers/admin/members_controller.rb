class Admin::MembersController < Admin::ApplicationController

  def show
    @member = Member.includes(:member_notes).find(params[:id])
    @invitations = @member.session_invitations.attended.order_by_latest rescue nil
    @last_attendance = @invitations.last.sessions if @invitations.any?
    @member_note = MemberNote.new
  end
end
