class Admin::MemberNotesController < Admin::ApplicationController
  before_action :authorize_note, only: %i[update destroy]
  def create
    @note = MemberNote.new(member_note_params)
    authorize @note

    @note.author = current_user
    if @note.save
      MemberActivityRecorder.record(actor: current_user, key: 'member_note.created',
                                    trackable: @note, recipient: @note.member)
    else
      flash[:error] = @note.errors.full_messages.to_sentence
    end
    redirect_back fallback_location: root_path
  end

  def member_note_params
    params.expect(member_note: %i[note member_id])
  end

  # member_id is create-only: updating must not move a note to another member,
  # because authorization was checked against the note's original member.
  def update_note_params
    params.expect(member_note: %i[note])
  end

  def update
    if @note.update(update_note_params)
      flash[:notice] = 'Note successfully updated.'
      redirect_to admin_member_path(@note.member)
    else
      flash[:error] = @note.errors.full_messages.to_sentence
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
end
