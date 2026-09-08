class Admin::MemberNotesController < Admin::ApplicationController
  def create
    @note = MemberNote.new(member_note_params)
    authorize @note

    @note.author = current_user
    if @note.save
      MemberActivityRecorder.record(actor: current_user, key: 'member_note.created',
                                    trackable: @note, recipient: @note.member)
    else
      flash[:error] = @note.errors.full_messages
    end
    redirect_back fallback_location: root_path
  end

  def member_note_params
    params.expect(member_note: %i[note member_id])
  end
end
