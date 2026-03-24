RSpec.describe ThreeMonthEmailService, type: :service do
  describe "#send_chaser" do
    subject(:call) { described_class.send_chaser }

    let(:chapter) { Fabricate(:chapter) }
    let(:students_group) { Fabricate(:group, name: "Students", chapter: chapter) }
    let(:coaches_group) { Fabricate(:group, name: "Coaches", chapter: chapter) }

    let!(:eligible_student) do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 6.months.ago),
        role: "Student",
        attended: true
      )
      member
    end

    let!(:already_emailed_student) do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(:member_email_delivery, member: member)
      member
    end

    let!(:student_with_recent_attendance) do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 1.month.ago),
        role: "Student",
        attended: true
      )
      member
    end

    let!(:student_with_old_attendance) do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 4.months.ago),
        role: "Student",
        attended: true
      )
      member
    end

    let!(:coach_member) do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: coaches_group)
      member
    end

    let!(:unsubscribed_member) { Fabricate(:member) }
    let!(:banned_student) do
      member = Fabricate(:banned_member)
      Fabricate(:subscription, member: member, group: students_group)
      member
    end
    let!(:student_without_toc) do
      member = Fabricate(:member_without_toc)
      Fabricate(:subscription, member: member, group: students_group)
      member
    end

    let!(:student_with_very_old_attendance) do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 14.months.ago),
        role: "Student",
        attended: true
      )
      member
    end

    it "emails only students who have not attended in the last 3 months and were not emailed before" do
      expect { perform_enqueued_jobs { call } }.to change(MemberEmailDelivery, :count).by(2)

      expect(MemberEmailDelivery.where(member: eligible_student)).to exist
      expect(MemberEmailDelivery.where(member: student_with_old_attendance)).to exist
    end

    it "does not email a member already present in member_email_deliveries" do
      expect { perform_enqueued_jobs { call } }
        .not_to change { MemberEmailDelivery.where(member: already_emailed_student).count }
    end

    it "does not email students with a recent attended workshop" do
      expect { perform_enqueued_jobs { call } }
        .not_to change { MemberEmailDelivery.where(member: student_with_recent_attendance).count }
    end

    it "does not email members without a student subscription" do
      perform_enqueued_jobs { call }

      expect(MemberEmailDelivery.where(member: coach_member)).to be_empty
      expect(MemberEmailDelivery.where(member: unsubscribed_member)).to be_empty
    end

    it "does not email banned students or students without accepted terms" do
      perform_enqueued_jobs { call }

      expect(MemberEmailDelivery.where(member: banned_student)).to be_empty
      expect(MemberEmailDelivery.where(member: student_without_toc)).to be_empty
    end

    it "does not email students who have not attended in the past year" do
      perform_enqueued_jobs { call }

      expect(MemberEmailDelivery.where(member: student_with_very_old_attendance)).to be_empty
    end

    it "sends only one chaser for a member with multiple student subscriptions" do
      member = Fabricate(:member)
      other_chapter = Fabricate(:chapter)
      other_students_group = Fabricate(:group, name: "Students", chapter: other_chapter)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(:subscription, member: member, group: other_students_group)

      perform_enqueued_jobs { call }

      expect(MemberEmailDelivery.where(member: member).count).to eq(1)
    end

    it "sends only one chaser for a member with multiple qualifying old attendances" do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 5.months.ago),
        role: "Student",
        attended: true
      )
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 4.months.ago),
        role: "Student",
        attended: true
      )

      perform_enqueued_jobs { call }

      expect(MemberEmailDelivery.where(member: member).count).to eq(1)
    end

    it "does not send chasers when there are no eligible members" do
      Fabricate(
        :workshop_invitation,
        member: eligible_student,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 1.month.ago),
        role: "Student",
        attended: true
      )
      Fabricate(
        :workshop_invitation,
        member: student_with_old_attendance,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 1.month.ago),
        role: "Student",
        attended: true
      )

      expect { perform_enqueued_jobs { call } }.not_to change(MemberEmailDelivery, :count)
    end

    it "emails a student member who has recent attendance only as a coach" do
      member = Fabricate(:member)
      Fabricate(:subscription, member: member, group: students_group)
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 6.months.ago),
        role: "Student",
        attended: true
      )
      Fabricate(
        :workshop_invitation,
        member: member,
        workshop: Fabricate(:workshop, chapter: chapter, date_and_time: 1.month.ago),
        role: "Coach",
        attended: true
      )

      perform_enqueued_jobs { call }

      expect(MemberEmailDelivery.where(member: member)).to exist
    end
  end
end
