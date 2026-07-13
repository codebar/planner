class Admin::MemberNotesController < Admin::ApplicationController
  before_action :authorize_note, only: %i[update destroy]

  def create
    @note = MemberNote.new(member_note_params)
    authorize @note

    @note.author = current_user
    flash[:error] = @note.errors.full_messages unless @note.save
    redirect_back fallback_location: root_path
  end

  def edit; end

  def update
    if @note.update(member_note_params)
      flash[:notice] = 'Note successfully updated.'
      redirect_to admin_member_path(@note.member)
    else
      flash[:error] = @note.errors.full_messages unless @note.save
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    if @note.destroy
      flash[:notice] = 'Note successfully deleted.'
    else
      flash[:error] = 'Failed to delete note.'
    end
    redirect_back fallback_location: root_path
  end

  def authorize_note
    @note = MemberNote.find(params[:id])
    authorize @note
  end

  def member_note_params
    params.expect(member_note: [:note, :member_id])
  end
end
