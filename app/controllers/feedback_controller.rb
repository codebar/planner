class FeedbackController < ApplicationController

  def show
    feedback_request = FeedbackRequest.find_by(token: params[:id], submited: false)
    redirect_to action: 'not_found' and return if feedback_request.nil?

    set_coaches(feedback_request.sessions)

    @session = feedback_request.sessions
    @feedback = Feedback.new
  end

  def submit
    if Feedback.submit_feedback(feedback_params, params[:id])
      flash[:notice] = I18n.t("messages.feedback_saved")

      redirect_to root_path
    else
      feedback_request = FeedbackRequest.find_by(token: params[:id], submited: false)
      set_coaches(feedback_request.sessions)

      @session = feedback_request.sessions
      @feedback = Feedback.new(feedback_params)
      @feedback.valid?

      flash[:alert] = @feedback.errors.full_messages.to_sentence
      render 'show'
    end
  end

  def not_found; end

  def success; end

  private

  def feedback_params
    params.require(:feedback).permit(:coach_id, :tutorial_id, :request, :rating, :suggestions)
  end

  def set_coaches(workshop)
    @coaches = workshop.invitations.to_coaches.attended.map(&:member)
  end
end
