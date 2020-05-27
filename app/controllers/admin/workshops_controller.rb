class Admin::WorkshopsController < Admin::ApplicationController
  include  Admin::SponsorConcerns
  include  Admin::WorkshopConcerns

  before_action :set_workshop_by_id, only: %i[show edit destroy update]
  before_action :set_and_decorate_workshop, only: %i[attendees_checklist attendees_emails send_invites]

  WORKSHOP_DELETION_TIME_FRAME_SINCE_CREATION = 4.hours

  def index
    @chapter = Chapter.find(chapter_id)
    authorize @chapter
    @workshops = @chapter.workshops.includes(:sponsors)
  end

  def new
    @workshop = Workshop.new
    authorize @workshop
  end

  def create
    @workshop = Workshop.new(workshop_params)
    authorize(@workshop)

    if workshop_type_valid? && @workshop.save
      grant_organiser_access(@workshop.chapter.organisers.pluck(:id))
      set_host(host_id)

      redirect_to admin_workshop_path(@workshop), notice: I18n.t('admin.messages.workshop.created')
    else
      flash[:warning] = @workshop.errors.full_messages
      render 'new'
    end
  end

  def edit
    authorize @workshop
  end

  def show
    authorize @workshop
    @workshop = WorkshopPresenter.decorate(@workshop)
    if request.format.csv?
      csv_to_render = params[:type].eql?('labels') ? @workshop.attendees_csv : @workshop.pairing_csv
      return render text: csv_to_render
    end

    set_admin_workshop_data
  end

  def update
    authorize @workshop

    @workshop.assign_attributes(workshop_params)

    if workshop_type_valid? && @workshop.valid?
      @workshop.save
      update_workshop_details

      redirect_to admin_workshop_path(@workshop), notice: I18n.t('admin.messages.workshop.updated')
    else
      flash[:warning] = @workshop.errors.full_messages
      render 'edit'
    end
  end

  def send_invites; end

  def attendees_checklist
    return render text: @workshop.attendees_checklist if request.format.text?

    redirect_to admin_workshop_path(@workshop),
                notice: I18n.t('messages.invalid_format', invalid_format: request.format)
  end

  def attendees_emails
    return render text: @workshop.attendees_emails if request.format.text?

    redirect_to admin_workshop_path(@workshop)
  end

  def invite
    set_workshop
    authorize @workshop
    audience = params[:for]

    if @workshop.virtual?
      InvitationManager.new.send_virtual_workshop_emails(@workshop, audience)
    else
      InvitationManager.new.send_workshop_emails(@workshop, audience)
    end

    redirect_to admin_workshop_path(@workshop), notice: "Invitations to #{audience} are being emailed out."
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
    params.require(:workshop).permit(
      :chapter_id,
      :local_date, :local_time, :local_end_time,
      :invitable,
      :seats,
      :description,
      :rsvp_open_local_date, :rsvp_open_local_time,
      :virtual,
      :slack_channel,
      :slack_channel_link,
      :coach_spaces, :student_spaces,
      sponsor_ids: []
    )
  end

  def chapter_id
    params.permit(:chapter_id)[:chapter_id]
  end

  def set_workshop_by_id
    @workshop = Workshop.find(params[:id])
  end

  def set_and_decorate_workshop
    workshop = Workshop.find(params[:workshop_id])
    @workshop = WorkshopPresenter.decorate(workshop)
  end

  def workshop_id
    params.permit(:workshop_id)[:workshop_id]
  end

  def set_host(host_id)
    return unless host_id

    host = @workshop.workshop_sponsors.find_or_initialize_by(sponsor_id: host_id)
    return if @workshop.host.eql?(host.sponsor)

    @workshop.workshop_sponsors.where(sponsor: @workshop.host).destroy_all
    host.update(host: true)
  end

  def set_organisers(organiser_ids)
    organiser_ids.reject!(&:empty?)
    grant_organiser_access(organiser_ids)
    revoke_organiser_access(organiser_ids)
  end

  def host_id
    params.require(:workshop).permit(:host)[:host]
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

  def physical_workshop_and_no_host?(workshop)
    !workshop.virtual && host_id.empty?
  end

  def workshop_type_valid?
    return true unless physical_workshop_and_no_host?(@workshop)

    @workshop.errors.add(:host, "can't be blank")
    false
  end

  def update_workshop_details
    set_organisers(organiser_ids)
    set_host(host_id)
  end
end
