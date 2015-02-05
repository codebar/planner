class Admin::MemberNotesController < Admin::ApplicationController
  def create
    @note = MemberNote.new(member_note_params)
    authorize @note
    @note.author = current_user
    flash[:error] = @note.errors.full_messages unless @note.save
    redirect_to :back
  end

  def member_note_params
    params.require(:member_note).permit(:note, :member_id)
  end
end
