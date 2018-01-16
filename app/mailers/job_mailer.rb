class JobMailer < ActionMailer::Base
  include ApplicationHelper

  helper ApplicationHelper

  def job_approved(job)
    @job = job
    @member = @job.created_by
    mail(mail_args(@member, "Job #{@job.title} at #{@job.company} approved"))
  end

  private
  def mail_args(member, subject)
    { from: 'codebar.io <notifications@codebar.io>',
      to: member.email,
      subject: subject }
  end

  helper do
    def full_url_for(path)
      "#{@host}#{path}"
    end
  end
end
