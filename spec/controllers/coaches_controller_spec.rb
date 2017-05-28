require 'spec_helper'

describe CoachesController, type: :controller do
  let!(:chapter) { Fabricate(:coach).chapters.first }
  let!(:coaches) { chapter.coaches.to_a }
  let!(:high_attendance_coach) { coaches.delete_at(rand(coaches.length)) }
  let!(:low_attendance_coach) { coaches.delete_at(rand(coaches.length)) }

  describe ".coaches" do
    before do
      allow(controller).to receive(:chapter).and_return(chapter)

      # Add 2 sessions attended to the high attendance coach
      2.times do
        Fabricate(:attended_session_invitation, role: "Coach", member: high_attendance_coach, workshop: Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.now) )
      end

      # Add a session attended to remaining coaches
      coaches.each do |coach|
        Fabricate(:attended_session_invitation, role: "Coach", member: coach, workshop: Fabricate(:workshop, chapter: chapter, date_and_time: Time.zone.now+14.days) )
      end
    end

    it "Returns an array of coaches with those with highest attendance first" do
      # Make sure neither coach is the same.
      expect(high_attendance_coach).to_not eq(low_attendance_coach)

      # All coaches have a different attended sessions amount.
      expect(high_attendance_coach.attended_sessions.count).to eq(2)
      expect(coaches.collect { |coach| coach.attended_sessions.count }.uniq).to eq([1])
      expect(low_attendance_coach.attended_sessions.count).to eq(0)

      expect(controller.send(:coaches).first).to eq(high_attendance_coach)
      expect(controller.send(:coaches).last).to eq(low_attendance_coach)
    end
  end
end
