class Admin::WorkshopsController < Admin::ApplicationController
  include  Admin::SponsorConcerns
  include  Admin::WorkshopConcerns

  before_filter :set_workshop_by_id, only: %i[show edit destroy]
  before_filter :set_and_decorate_workshop, only: %i[attendees_checklist attendees_emails]

  WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION = 4.hours

  def index
    @chapter = Chapter.find(params[:chapter_id])
    authorize @chapter
  end

  def new
    @workshop = Workshop.new
    authorize @workshop
  end

  def create
    @workshop = Workshop.new(workshop_params)
    authorize(@workshop)

    if @workshop.save
      grant_organiser_access(@workshop.chapter.organisers.map(&:id))
      set_host(host_id)

      redirect_to admin_workshop_path(@workshop), notice: 'The workshop has been created.'
    else
      flash[:notice] = @workshop.errors.full_messages
      render 'new'
    end
  end

  def edit
    authorize @workshop
  end

  def show
    authorize @workshop

    @workshop = WorkshopPresenter.new(@workshop)
    return render text: @workshop.attendees_csv if request.format.csv?

    @address = AddressPresenter.new(@workshop.host.address) if @workshop.has_host?
    set_admin_workshop_data
  end

  def update
    @workshop = Workshop.find(params[:id])
    authorize @workshop

    @workshop.update_attributes(workshop_params)

    set_organisers(organiser_ids)
    set_host(host_id)

    redirect_to admin_workshop_path(@workshop), notice: 'Workshops updated successfully'
  end

  def send_invites
    @workshop = WorkshopPresenter.new(Workshop.find(params[:workshop_id]))
  end

  def attendees_checklist
    return render text: @workshop.attendees_checklist if request.format.text?

    redirect_to admin_workshop_path(@workshop)
  end

  def attendees_emails
    return render text: @workshop.attendees_emails if request.format.text?

    redirect_to admin_workshop_path(@workshop)
  end

  def invite
    set_workshop
    authorize @workshop
    audience = params[:for]

    InvitationManager.new.send_workshop_emails(@workshop, audience)

    redirect_to admin_workshop_path(@workshop), notice: 'Invitations are being emailed out.'
  end

  def destroy
    authorize(@workshop)

    if workshop_has_no_invitees? && workshop_created_within_specific_time_frame?
      @workshop.destroy

      redirect_to admin_root_path, notice: t('admin.workshop.destroy.success')
    else
      redirect_to admin_workshop_path(@workshop), notice: t('admin.workshop.destroy.failure')
    end
  end

  private

  def workshop_params
    params.require(:workshop).permit(:local_date, :local_time, :chapter_id,
                                     :invitable, :seats, :rsvp_open_local_date,
                                     :rsvp_open_local_time, sponsor_ids: [])
  end

  def sponsor_id
    workshop_params[:sponsor_ids][1]
  end

  def set_workshop_by_id
    @workshop = Workshop.find(params[:id])
  end

  def set_and_decorate_workshop
    workshop = Workshop.find(params[:workshop_id])
    @workshop = WorkshopPresenter.new(workshop)
  end

  def workshop_id
    params[:workshop_id] || params[:id]
  end

  def set_host(host_id)
    return unless host_id

    host = @workshop.workshop_sponsors.find_or_initialize_by(sponsor_id: host_id)
    unless @workshop.host.eql?(host.sponsor)
      @workshop.workshop_sponsors.where(sponsor: @workshop.host).destroy_all
      host.update(host: true)
    end
  end

  def set_organisers(organiser_ids)
    organiser_ids.reject!(&:empty?)
    grant_organiser_access(organiser_ids)
    revoke_organiser_access(organiser_ids)
  end

  def host_id
    params[:workshop][:host]
  end

  def organiser_ids
    params[:workshop][:organisers]
  end

  def grant_organiser_access(organiser_ids = [])
    organiser_ids.each { |id| Member.find(id).add_role(:organiser, @workshop) }
  end

  def revoke_organiser_access(organiser_ids)
    (@workshop.organisers.pluck(:id).map(&:to_s) - organiser_ids).each do |id|
      Member.find(id).revoke(:organiser, @workshop)
    end
  end

  def workshop_has_no_invitees?
    @workshop.invitations.blank?
  end

  def workshop_created_within_specific_time_frame?
    Time.zone.now.between?(@workshop.created_at,
                           @workshop.created_at + WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION)
  end
end
