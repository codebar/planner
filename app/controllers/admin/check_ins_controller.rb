# frozen_string_literal: true

class Admin::CheckInsController < Admin::ApplicationController
  before_action :load_parent

  def show
    authorize @parent
    @parent.generate_check_in_code! if @parent.check_in_code.blank?

    respond_to do |format|
      format.html
      format.pdf do
        pdf = CheckInPdf.new(@parent).render
        send_data pdf,
                  filename: "check-in-#{@parent.to_param}.pdf",
                  type: "application/pdf",
                  disposition: "attachment"
      end
    end
  end

  private

  def load_parent
    if params[:event_id]
      @parent = Event.find_by!(slug: params[:event_id])
    elsif params[:workshop_id]
      @parent = Workshop.find(params[:workshop_id])
    end
  end
end
