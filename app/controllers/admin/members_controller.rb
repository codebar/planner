class Admin::MembersController < Admin::ApplicationController

  def show
    @member = Member.includes(:member_notes).find(params[:id])
    @member_note = MemberNote.new
  end
end
