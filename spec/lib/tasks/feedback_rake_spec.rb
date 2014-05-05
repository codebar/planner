require "spec_helper"

describe "feedback:request" do
  include_context "rake"

  its(:prerequisites) { should include("environment") }

  context "when most recent sessions has attended student" do
    let(:session)          { Fabricate(:sessions, date_and_time: 1.day.ago) }
    let(:student)          { Fabricate(:student) }

    before do
      STDOUT.stub(:puts)
      student.session_invitations << Fabricate(:attended_session_invitation, member: student, sessions: session)
    end

    it 'should gracefully run' do
      expect { subject.invoke }.to_not raise_error
    end

    it "generates a FeedbackRequest" do
      FeedbackRequest.should_receive(:create).with(member: student, sessions: session, submited: false)

      subject.invoke
    end
  end
end
