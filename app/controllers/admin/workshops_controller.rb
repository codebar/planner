class Admin::WorkshopsController < Admin::ApplicationController
  include  Admin::SponsorConcerns

  before_filter :set_workshop_by_id, only: [:show, :edit]

  def index
    @chapter = Chapter.find(params[:chapter_id])
    authorize @chapter
  end

  def new
    @workshop = Sessions.new
    authorize @workshop
  end

  def create
    @workshop = Sessions.new(workshop_params)
    authorize @workshop
    if @workshop.save
      flash[:notice] = @workshop.errors.full_messages
      redirect_to admin_workshop_path(@workshop)
    else
      render 'new'
    end
  end

  def edit
    authorize @workshop
  end

  def show
    authorize @workshop
    @coach_waiting_list = WaitingListPresenter.new(WaitingList.by_workshop(@workshop).where_role("Coach"))
    @student_waiting_list = WaitingListPresenter.new(WaitingList.by_workshop(@workshop).where_role("Student"))
  end

  def update
    @workshop = Sessions.find(params[:id])
    authorize @workshop
    @workshop.update_attributes(workshop_params)
    redirect_to admin_workshop_path(@workshop), notice: "Workshops updated succesfully"
  rescue Exception => e
    redirect_to admin_workshop_path(@workshop), notice: e.inspect
  end

  def invite
    set_workshop
    authorize @workshop

    InvitationManager.send_session_emails(@workshop)

    redirect_to admin_workshop_path(@workshop), notice: "Invitations sent!"
  end

  private

  def workshop_params
    params.require(:sessions).permit(:date_and_time, :time, :chapter_id, :invitable, :seats, sponsor_ids: [])
  end

  def sponsor_id
    workshop_params[:sponsor_ids][1]
  end

  def set_workshop_by_id
    @workshop = Sessions.find(params[:id])
  end
end
