module Admin::WorkshopConcerns
  extend ActiveSupport::Concern

  included do
    include InstanceMethods
  end

  module InstanceMethods
    def set_admin_workshop_data
      @attending_students = InvitationPresenter.decorate_collection(
        @workshop.attending_students.all.with_notes_and_their_authors
      )
      @attending_coaches = InvitationPresenter.decorate_collection(
        @workshop.attending_coaches.all.with_notes_and_their_authors
      )

      @coach_waiting_list = WaitingListPresenter.new(
        WaitingList.by_workshop(@workshop).where_role('Coach').order(:created_at).with_notes_and_their_authors
      )
      @student_waiting_list = WaitingListPresenter.new(
        WaitingList.by_workshop(@workshop).where_role('Student').order(:created_at).with_notes_and_their_authors
      )
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
