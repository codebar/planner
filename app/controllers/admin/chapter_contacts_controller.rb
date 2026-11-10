class Admin::ChapterContactsController < Admin::ApplicationController
  before_action :set_chapter, only: %i[new preview create]
  after_action :verify_authorized

  def index
    authorize Chapter, :contact_index?
    @chapters = accessible_chapters
  end

  def new
    authorize @chapter, :contact?
    @chapter_members = @chapter.contact_members
    @chapter_events = @chapter.contact_events
    @audience = 'all_members'
    @recipient_count = @chapter.contact_recipients(@audience).count
    @selected_member_ids = []
  end

  def preview
    authorize @chapter, :contact?
    recipient_ids = preview_recipient_ids
    return render(:new, status: :unprocessable_entity) unless valid_contact?(recipient_ids)

    create_confirmation(recipient_ids)
    render :preview
  end

  def create
    authorize @chapter, :contact?
    token = confirmation_token
    return reject_confirmation unless token

    confirmation = ChapterContactConfirmation.find_for(chapter: @chapter, sender: current_user, token:)
    return reject_confirmation unless confirmation&.consume! { |record| send_contact_emails(record) }

    count = confirmation.recipient_ids.size
    redirect_to new_admin_chapter_contact_path(@chapter),
                notice: "Email sent to #{count} chapter #{'member'.pluralize(count)}"
  end

  private

  def preview_params
    params.expect(chapter_contact: [:subject, :message, :audience, :event_id, :rsvp_status, { member_ids: [] }])
  end

  def confirmation_token
    token = params[:chapter_contact]&.[](:confirmation_token)
    token if token.is_a?(String) && token.present?
  end

  def preview_recipient_ids
    attributes = preview_params
    @subject, @message = attributes.values_at(:subject, :message)
    @audience = attributes[:audience].presence || 'all_members'
    @selected_member_ids = Array(attributes[:member_ids])
    @event_id, @rsvp_status = attributes.values_at(:event_id, :rsvp_status)
    @chapter_members = @chapter.contact_members
    @chapter_events = @chapter.contact_events
    @chapter.contact_recipients(
      @audience, @selected_member_ids, event_id: @event_id, rsvp_status: @rsvp_status
    ).pluck(:id)
  end

  def valid_contact?(recipient_ids)
    @recipient_count = recipient_ids.size
    return true if @audience.in?(Chapter::CONTACT_AUDIENCES) &&
                   @subject.present? && @message.present? && recipient_ids.any?

    flash.now[:alert] = contact_error
    false
  end

  def create_confirmation(recipient_ids)
    confirmation = ChapterContactConfirmation.create_for!(
      chapter: @chapter,
      sender: current_user,
      subject: @subject,
      message: @message,
      recipient_ids:
    )
    @confirmation_token = confirmation.token
    @recipient_count = confirmation.recipient_ids.size
    @recipients = Member.where(id: confirmation.recipient_ids).order(:name, :surname)
  end

  def accessible_chapters
    global_organiser = current_user.roles.where(name: 'organiser', resource_type: nil, resource_id: nil).exists?
    return Chapter.order(:name) if current_user.is_admin? || global_organiser

    current_user.organised_chapters.order(:name)
  end

  def contact_error
    return 'Subject and message are required.' if @subject.blank? || @message.blank?
    return 'Choose a valid audience.' unless @audience.in?(Chapter::CONTACT_AUDIENCES)

    {
      'chapter_organisers' => 'There are no chapter organisers to email.',
      'custom_list' => 'Select at least one current chapter member.',
      'active_last_month' => 'There are no members active in the last month to email.',
      'inactive_last_month' => 'There are no members inactive for the last month to email.',
      'event_rsvp' => 'No current chapter members match that event RSVP status.'
    }.fetch(@audience, 'There are no current chapter subscribers to email.')
  end

  def reject_confirmation
    redirect_to new_admin_chapter_contact_path(@chapter),
                alert: 'Email preview expired or already used; please preview again.'
  end

  def send_contact_emails(confirmation)
    Member.where(id: confirmation.recipient_ids).find_each do |member|
      ChapterContactMailer.with(chapter: confirmation.chapter, recipient: member,
                                subject: confirmation.subject, message: confirmation.message)
                          .contact.deliver_later
    end
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
end
