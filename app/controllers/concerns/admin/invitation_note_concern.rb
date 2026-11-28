module Admin
  module InvitationNoteConcern
    extend ActiveSupport::Concern

    private

    def handle_note_update
      if @invitation.update(sanitized_note_params)
        MemberActivityRecorder.record(actor: current_user, key: 'invitation.note_updated',
                                      trackable: @invitation, recipient: @invitation.member)
        render_note_update_success
      else
        render_note_update_failure
      end
    end

    def sanitized_note_params
      params.expect(workshop_invitation: [:note]).to_h.transform_values { |v| v.to_s.strip.presence }
    end

    def render_note_update_success
      if request.xhr?
        inject_attendance_flags([@invitation])
        render partial: 'admin/workshop/attendance_row',
               locals: { invitation: InvitationPresenter.new(@invitation), workshop: @workshop }
      else
        redirect_back fallback_location: root_path, notice: "Updated note for #{@invitation.member.full_name}."
      end
    end

    def render_note_update_failure
      error_message = @invitation.errors.full_messages.to_sentence
      if request.xhr?
        render plain: error_message, status: :unprocessable_content
      else
        redirect_back fallback_location: root_path, alert: error_message
      end
    end
  end
end
