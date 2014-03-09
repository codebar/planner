require "spec_helper"

describe "feedback:request" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }

  context "when most recent sessions has attended student" do
    let(:session)          { Fabricate(:sessions, date_and_time: 1.day.ago) }
    let(:student)          { Fabricate(:student) }

    before do
      STDOUT.stub(:puts)
      STDOUT.stub(:print)
      STDIN.stub(:gets).and_return('y')
      student.session_invitations << Fabricate(:attended_session_invitation, member: student, sessions: session)
    end

    it 'should gracefully run' do
      expect { subject.invoke }.to_not raise_error
    end

    it "generates a FeedbackRequest" do
      FeedbackRequest.stub(:create)
      subject.invoke
      FeedbackRequest.should have_received(:create).with(member: student, sessions: session, submited: false)
    end

    context "confirmation message" do
      it "is displayed" do
        confirmation_message = "Do you want to send feedback requests for session: #{session.title}? (y/N) "

        subject.invoke
        STDOUT.should have_received(:print).with(confirmation_message)
      end

      it "terminates rake task if negative answer is given" do
        FeedbackRequest.stub(:create)
        STDIN.stub(:gets).and_return('N')

        subject.invoke
        FeedbackRequest.should_not have_received(:create)
      end
    end
  end

  context "when there is no sessions" do
    it "raises error" do
      expect { subject.invoke }.to raise_error(RuntimeError, 'Sorry. No recent sessions found.')
    end
  end
end