class Admin::MeetingsController < Admin::ApplicationController
  before_action :set_meeting, except: %i[new create]

  def new
    @meeting = Meeting.new
  end

  def create
    @meeting = Meeting.new(meeting_params)
    set_organisers(organiser_ids)
    set_chapters(chapter_ids)

    if @meeting.save
      redirect_to [:admin, @meeting], notice: t('admin.messages.meeting.created')
    else
      flash[:notice] = @meeting.errors.full_messages.join('<br/>')
      render :new
    end
  end

  def show
    @invitations = @meeting.invitations.accepted.includes(:member).order(:created_at)

    return render text: @meeting.attendees_csv if request.format.csv?
  end

  def edit; end

  def update
    set_organisers(organiser_ids)
    set_chapters(chapter_ids)

    if @meeting.update(meeting_params)
      redirect_to [:admin, @meeting], notice: t('admin.messages.meeting.updated')
    else
      flash[:notice] = @meeting.errors.full_messages.join('<br/>')
      render 'edit'
    end
  end

  def attendees_emails
    meeting = MeetingPresenter.new(@meeting)
    return render text: meeting.attendees_emails if request.format.text?

    redirect_to admin_meeting_path(@meeting)
  end

  def invite
    if @meeting.invites_sent
      return redirect_to admin_meeting_path(@meeting),
                         notice: t('admin.messages.meeting.invitations_already_sent')
    end

    @meeting.invitees.not_banned.each do |invitee|
      invitation = MeetingInvitation
        .create(meeting: @meeting, member: invitee, role: 'Participant')
      MeetingInvitationMailer.invite(@meeting, invitee, invitation).deliver_now
    end
    @meeting.update_attribute(:invites_sent, true)

    redirect_to admin_meeting_path(@meeting), notice: t('admin.messages.meeting.sending_invitations')
  end

  private

  def set_meeting
    @meeting = Meeting.find_by(slug: slug)
  end

  def slug
    params.permit(:id)[:id]
  end

  def meeting_params
    params.require(:meeting).permit(
      :name, :description, :slug, :date_and_time, :local_date, :local_time, :local_end_time,
      :invitable, :spaces, :venue_id, :sponsor_id, :chapters
    )
  end

  def organiser_ids
    params[:meeting][:organisers]
  end

  def chapter_ids
    params[:meeting][:chapters]
  end

  def grant_organiser_access(organiser_ids = [])
    organiser_ids.each { |id| Member.find(id).add_role(:organiser, @meeting) }
  end

  def revoke_organiser_access(organiser_ids)
    (@meeting.organisers.pluck(:id).map(&:to_s) - organiser_ids).each do |id|
      Member.find(id).revoke(:organiser, @meeting)
    end
  end

  def set_organisers(organiser_ids)
    organiser_ids.reject!(&:empty?)
    grant_organiser_access(organiser_ids)
    revoke_organiser_access(organiser_ids)
  end

  def set_chapters(chapter_ids)
    chapter_ids.reject!(&:empty?)
    @meeting.chapters = chapter_ids.map { |id| Chapter.find(id) }
  end
end
