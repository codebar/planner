require 'spec_helper'

describe WorkshopPresenter do
  let(:invitations) { [Fabricate(:student_session_invitation),
                       Fabricate(:student_session_invitation),
                       Fabricate(:coach_session_invitation)] }
  let(:sessions) { double(:workshop, attendances: invitations )}
  let(:workshop) { WorkshopPresenter.new(sessions) }

  it "#attendess_csv" do

    invitations.each do |invitation|
      expect(workshop.attendees_csv).to include(invitation.member.full_name)
      expect(workshop.attendees_csv).to include(invitation.role.upcase)
    end
  end
end
