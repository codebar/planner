class CourseInvitationMailer < ActionMailer::Base
  include EmailHeaderHelper

  helper ApplicationHelper

  def invite_student(course, member, invitation)
    @course = CoursePresenter.new(course)
    @member = member
    @invitation = invitation

    subject = "Course :: #{@course.title} by codebar - #{l(@course.date_and_time, format: :email_title)}"

    mail(mail_args(member, subject)) do |format|
      format.html
    end
  end

  private

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end
end
