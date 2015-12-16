require 'spec_helper'

RSpec.describe AllocateSpacesJob, type: :job do
  context "workshop with random allocation" do
    let(:workshop) { Fabricate(:sessions_random_allocate) }

    it "does nothing when no students are waiting" do
      AllocateSpacesJob.new.perform(workshop)

      expect(workshop.attending_students).to eq([])
      expect(workshop.attending_coaches).to eq([])
    end

    it "assigns a student from the waitlist" do
      invitation = Fabricate(:session_invitation, sessions: workshop, role: "Student")
      WaitingList.add(invitation)

      AllocateSpacesJob.new.perform(workshop)

      expect(workshop.attending_students).to eq([invitation])
      expect(workshop.attending_coaches).to eq([])
    end

    it "assigns all members from the waitlist, if they will fit" do
      student_invitations = workshop.host.seats.times.map {
        |n| Fabricate(:session_invitation, sessions: workshop, role: "Student") }
      student_invitations.map { |invitation| WaitingList.add(invitation) }

      coach_invitations = workshop.host.coach_spots.times.map {
        |n| Fabricate(:session_invitation, sessions: workshop, role: "Coach") }
      coach_invitations.map { |invitation| WaitingList.add(invitation) }

      AllocateSpacesJob.new.perform(workshop)

      expect(workshop.attending_students).to match_array(student_invitations)
      expect(workshop.attending_coaches).to match_array(coach_invitations)
    end

    it "assigns members up to the seat limit" do
      student_count = workshop.host.seats * 2
      coach_count = workshop.host.coach_spots * 2

      student_invitations = student_count.times.map {
        |n| Fabricate(:session_invitation, sessions: workshop, role: "Student") }
      student_invitations.map { |invitation| WaitingList.add(invitation) }

      coach_invitations = coach_count.times.map {
        |n| Fabricate(:session_invitation, sessions: workshop, role: "Coach") }
      coach_invitations.map { |invitation| WaitingList.add(invitation) }

      AllocateSpacesJob.new.perform(workshop)

      expect(workshop.attending_students
            ).to all(satisfy {|i| student_invitations.include?(i)})
      expect(workshop.attending_coaches
            ).to all(satisfy {|i| coach_invitations.include?(i)})

      expect(workshop.attending_students.length).to eq(workshop.host.seats)
      expect(workshop.attending_coaches.length).to eq(workshop.host.coach_spots)
    end
  end

  context "workshop with random allocation time in the future" do
    let(:workshop) { Fabricate(:sessions_random_allocate,
                               random_allocate_at: DateTime.now+2.days) }

    it "reschedules itself" do
      invitations = workshop.host.seats.times.map {
        |n| Fabricate(:session_invitation, sessions: workshop) }
      invitations.map { |invitation| WaitingList.add(invitation) }

      # Fabricating the session will have enqueued an allocation job
      # for it, so clear the queue
      ActiveJob::Base.queue_adapter.enqueued_jobs = []

      AllocateSpacesJob.new.perform(workshop)

      expect(ActiveJob::Base.queue_adapter.enqueued_jobs
            ).to contain_exactly(a_hash_including(job: AllocateSpacesJob,
                                                  at: workshop.random_allocate_at.to_i))

      expect(workshop.attending_students).to eq([])
      expect(workshop.attending_coaches).to eq([])
    end
  end

  context "workshop without random allocation" do
    let(:workshop) { Fabricate(:sessions) }

    it "does nothing" do
      invitations = workshop.host.seats.times.map {
        |n| Fabricate(:session_invitation, sessions: workshop) }
      invitations.map { |invitation| WaitingList.add(invitation) }

      AllocateSpacesJob.new.perform(workshop)

      expect(workshop.attending_students).to eq([])
      expect(workshop.attending_coaches).to eq([])
    end
  end
end
