class Admin::WorkshopsController < Admin::ApplicationController
  include  Admin::SponsorConcerns
  include  Admin::WorkshopConcerns

  before_filter :set_workshop_by_id, only: [:show, :edit, :destroy]
  before_filter :set_and_decorate_workshop, only: [:attendees_checklist, :attendees_emails]

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
      set_organisers(@workshop.chapter.organisers.map(&:id).map(&:to_s) + organiser_ids)
      set_host(host_id)
      update_rsvp_open_time if auto_rsvps_set?

      redirect_to admin_workshop_path(@workshop), notice: "The workshop has been created."
    else
      flash[:notice] = @workshop.errors.full_messages
      render 'new'
    end
  end

  def edit
    authorize @workshop

    @rsvp_open_time = @workshop.rsvp_open_time.try(:strftime, '%H:%M')
    @rsvp_open_date = @workshop.rsvp_open_date.try(:strftime, '%d/%m/%Y')
  end

  def show
    authorize @workshop

    @workshop = WorkshopPresenter.new(@workshop)
    return render text: @workshop.attendees_csv if request.format.csv?

    @address = AddressDecorator.decorate(@workshop.host.address) if @workshop.has_host?
    set_admin_workshop_data
  end

  def update
    @workshop = Workshop.find(params[:id])
    authorize @workshop

    @workshop.update_attributes(workshop_params)

    set_organisers(organiser_ids)
    set_host(host_id)
    update_rsvp_open_time if auto_rsvps_set?

    redirect_to admin_workshop_path(@workshop), notice: "Workshops updated successfully"
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

    InvitationManager.new.send_session_emails(@workshop, audience)

    redirect_to admin_workshop_path(@workshop), notice: "Invitations are being emailed out."
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

  def auto_rsvps_set?
    @workshop.rsvp_open_time.present? && @workshop.rsvp_open_date.present?
  end

  def update_rsvp_open_time
    updated_time = DateTime.new(@workshop.rsvp_open_date.year, @workshop.rsvp_open_date.month, @workshop.rsvp_open_date.day, @workshop.rsvp_open_time.hour, @workshop.rsvp_open_time.min)
    @workshop.update_attribute(:rsvp_open_time, updated_time)
  end

  def workshop_params
    params.require(:workshop).permit(:date_and_time, :time, :chapter_id,
    :invitable, :seats, :rsvp_open_time, :rsvp_open_date, sponsor_ids: [])
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
      @workshop.workshop_sponsors.where(sponsor: @workshop.host).delete_all
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

  def grant_organiser_access(organiser_ids=[])
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
