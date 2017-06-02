require 'spec_helper'

describe Chapter do

  context "validations" do
    context "#slug" do
      it "a chapter must have a slug set" do
        chapter = Chapter.new(name: "London", city: "London", email: "london@codebar.io")
        chapter.save

        expect(chapter.slug).to eq("london")
      end

      it "the slug is parameterized" do
        chapter = Chapter.new(name: "New York", city: "New York", email: "newyork@codebar.io")
        chapter.save

        expect(chapter.slug).to eq("new-york")
      end

      context "scopes" do
        context "#default_scope" do
          it "only returns active Chapters" do
            2.times { Fabricate(:chapter) }
            3.times { Fabricate(:chapter, active: false) }

            expect(Chapter.all.count).to eq(2)
          end
        end
      end
    end
  end

  describe ".coaches_by_attended_sessions" do
    let!(:subject) { Fabricate(:coach).chapters.first }
    let!(:coaches) { subject.coaches.to_a }

    # Remove a random coach and give them lots of attendance, so when we call 
    # `.coaches_by_attended_sessions` they'll appear first.
    let!(:high_attendance_coach) do
      coach = coaches.delete_at(rand(coaches.length))

      # Add a couple of attendances to this coach ( So it appears first )
      2.times do
        Fabricate(:attended_session_invitation, role: "Coach", member: coach, workshop: Fabricate(:workshop, chapter: subject, date_and_time: Time.zone.now) )
      end

      coach
    end

    # Remove a coach from the coaches array, so in the `before` we don't add any
    # attended sessions to them. This should make them appear last when calling
    # `.coaches_by_attended_sessions`
    let!(:low_attendance_coach) { coaches.delete_at(rand(coaches.length)) }

    before do
      # Add 1 session to the remaining coaches ( We have removed 
      # high_attendance_coach & low_attendance_coach from the array already )
      coaches.each do |coach|
        Fabricate(:attended_session_invitation, role: "Coach", member: coach, workshop: Fabricate(:workshop, chapter: subject, date_and_time: Time.zone.now+14.days) )
      end
    end

    it "Returns coaches with the highest attendance first" do
      expect(subject.coaches_by_attended_sessions.first).to eq(high_attendance_coach)
    end

    it "Returns coaches with the lowest attendance last" do
      expect(subject.coaches_by_attended_sessions.last).to eq(low_attendance_coach)
    end
    
  end
end
