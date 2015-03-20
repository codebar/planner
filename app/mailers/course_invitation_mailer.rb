class CourseInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper

  helper ApplicationHelper

  def invite_student course, member, invitation
    @course = CoursePresenter.new(course)
    @member = member
    @invitation = invitation

    load_attachments

    subject = "Course :: #{@course.title} by Codebar - #{l(@course.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  private

  def load_attachments
    %w{logo.png}.each do |image|
      attachments.inline[image] = File.read("#{Rails.root.to_s}/app/assets/images/#{image}")
    end
  end

  helper do
    def full_url_for path
      "#{@host}#{path}"
    end
  end
end
