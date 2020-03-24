class MeetingInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper
  include ApplicationHelper

  helper ApplicationHelper

  def invite(meeting, member)
    setup(meeting, member) do
      @rsvp_url = meeting_url(@meeting)
      "You are invited to codebar's #{@meeting.name} on #{l(@meeting.date_and_time, format: :humanize_date)}"
    end
  end

  def attending(meeting, member)
    setup(meeting, member) do
      @cancellation_url = meeting_url(@meeting)
      "See you at #{@meeting.name} on #{l(@meeting.date_and_time, format: :humanize_date)}"
    end
  end

  def approve_from_waitlist(meeting, member)
    setup(meeting, member) do
      @cancellation_url = meeting_url(@meeting)
      "A spot opened up for #{@meeting.name} on #{l(@meeting.date_and_time, format: :humanize_date)}"
    end
  end

  def attendance_reminder(meeting, member)
    setup(meeting, member) do
      @cancellation_url = meeting_url(@meeting)
      "Reminder: You have a spot for #{@meeting.name} on #{l(@meeting.date_and_time, format: :humanize_date)}"
    end
  end

  private

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end

  def setup(meeting, member)
    @member = member
    @meeting = meeting
    @host_address = AddressPresenter.new(@meeting.venue.address)
    subject = yield
    mail(mail_args(@member, subject), &:html)
  end
end
