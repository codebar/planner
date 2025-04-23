class Admin::MemberNotesController < Admin::ApplicationController
  def create
    @note = MemberNote.new(member_note_params)
    authorize @note

    @note.author = current_user
    flash[:error] = @note.errors.full_messages unless @note.save
    redirect_back fallback_location: root_path
  end

  def member_note_params
    params.require(:member_note).permit(:note, :member_id)
  end

  def edit
    @note = MemberNote.find(params[:id])
    authorize @note
  end
  
  def update
    @note = MemberNote.find(params[:id])
  
    if @note.update(member_note_params)
      flash[:notice] = "Note updated successfully."
      redirect_to admin_member_path(@note.member)
    else
      flash[:error] = @note.errors.full_messages unless @note.save
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    @note = MemberNote.find(params[:id])
    authorize @note
    if @note.destroy
      flash[:notice] = "Note successfully deleted."
    else
      flash[:error] = "Failed to delete note."
    end
    redirect_back fallback_location: root_path
  end
end
