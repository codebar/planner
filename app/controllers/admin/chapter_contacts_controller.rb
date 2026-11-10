class Admin::ChapterContactsController < Admin::ApplicationController
  before_action :set_chapter, only: %i[new create]
  after_action :verify_authorized

  def index
    authorize Chapter, :contact_index?
    @chapters = accessible_chapters
  end

  def new
    authorize @chapter, :contact?
    @recipient_count = recipients.count
  end

  def create
    authorize @chapter, :contact?
    @subject, @message = contact_params.values_at(:subject, :message)
    @recipient_count = recipients.count

    return render_new unless valid_contact?

    send_contact_emails
    redirect_to new_admin_chapter_contact_path(@chapter),
                notice: "Email sent to #{@recipient_count} chapter members"
  end

  private

  def contact_params
    params.expect(chapter_contact: %i[subject message])
  end

  def recipients
    @chapter.members.distinct
  end

  def accessible_chapters
    return Chapter.order(:name) if current_user.is_admin? || global_organiser?

    current_user.organised_chapters.order(:name)
  end

  def global_organiser?
    current_user.roles.where(name: 'organiser', resource_type: nil, resource_id: nil).exists?
  end

  def valid_contact?
    return true if @subject.present? && @message.present? && @recipient_count.positive?

    flash.now[:alert] = contact_error
    false
  end

  def contact_error
    return 'Subject and message are required.' if @subject.blank? || @message.blank?

    'There are no current chapter subscribers to email.'
  end

  def render_new
    render :new, status: :unprocessable_entity
  end

  def send_contact_emails
    recipients.find_each do |member|
      ChapterContactMailer.with(chapter: @chapter, recipient: member, subject: @subject, message: @message)
                          .contact.deliver_later
    end
  end

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end
end
