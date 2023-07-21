class MemberMailerPreview < ActionMailer::Preview
  def welcome_student
    MemberMailer.welcome_student(Member.first)
  end
  def welcome_coach
    MemberMailer.welcome_coach(Member.first)
  end
end
