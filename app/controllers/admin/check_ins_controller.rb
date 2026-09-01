# frozen_string_literal: true

class Admin::CheckInsController < Admin::ApplicationController
  before_action :load_check_in_target

  def show
    authorize @check_in_target
    @check_in_target.with_lock { @check_in_target.generate_check_in_code! if @check_in_target.check_in_code.blank? }

    respond_to do |format|
      format.html
      format.pdf do
        pdf = CheckInPdf.new(@check_in_target).render
        send_data pdf,
                  filename: "check-in-#{@check_in_target.to_param}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  private

  def load_check_in_target
    if params[:event_id]
      @check_in_target = Event.find_by!(slug: params[:event_id])
    elsif params[:workshop_id]
      @check_in_target = Workshop.find(params[:workshop_id])
    end
  end
end
