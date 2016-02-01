class Admin::MeetingsController < Admin::ApplicationController


  def new
    @meeting = Meeting.new
  end

  def create
    @meeting = Meeting.new(meeting_params)
    # set_organisers(organiser_ids)

    if @meeting.save
      redirect_to [:admin, @meeting], notice: 'Meeting successfully created.'
    else
      render :new, notice: 'Error'
    end
  end

  def show
    set_meeting
  end

  private

  def set_meeting
    @meeting = Meeting.find_by_slug(params[:id])
  end

  def meeting_params
    params.require(:meeting).permit(:name, :description, :slug, :date_and_time, :invitable, :spaces, :venue_id, :sponsor_id)
  end
end