module Admin::WorkshopConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    def set_admin_workshop_data
      students = @workshop.attending_students.all.with_notes_and_their_authors
      coaches  = @workshop.attending_coaches.all.with_notes_and_their_authors

      inject_attendance_flags(students, coaches)

      @attending_students = InvitationPresenter.decorate_collection(students)
      @attending_coaches  = InvitationPresenter.decorate_collection(coaches)

      @coach_waiting_list = WaitingListPresenter.new(
        WaitingList.coaches_for(@workshop).with_notes_and_their_authors
      )
      @student_waiting_list = WaitingListPresenter.new(
        WaitingList.students_for(@workshop).with_notes_and_their_authors
      )
    end

    def inject_attendance_flags(*collections)
      members = collections.flat_map { |collection| collection.map(&:member) }.uniq(&:id)
      flags = AdminWorkshopAttendeeFlags.for_members(members.map(&:id))
      members.each { |member| member.admin_workshop_flags = flags[member.id] }
    end

    private

    def set_workshop
      @workshop = Workshop.find(params[:workshop_id])
    end

    def set_and_decorate_workshop
      workshop = Workshop.find(params[:workshop_id])
      @workshop = WorkshopPresenter.decorate(workshop)
    end
  end
end
