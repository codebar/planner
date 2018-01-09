require 'spec_helper'

describe CourseInvitationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }

  it '#invite_student' do
    member = Fabricate(:member)
    course = Fabricate(:course, title: 'HTTP Fundamentals', date_and_time: Time.zone.local(2013, 10, 30, 18, 30))
    invitation_token = 'token'

    email_subject = "Course :: #{course.title} by codebar - Wednesday, 30 Oct at 18:30"
    CourseInvitationMailer.invite_student(course, member, invitation_token).deliver_now

    expect(email.subject).to eq(email_subject)
  end
end
