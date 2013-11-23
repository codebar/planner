require 'spec_helper'

describe Member do
  context "mandatory attributes" do
    context "validations" do
      context "presence" do
        it "#name" do
          member = Fabricate.build(:member, name: nil)

          member.should_not be_valid
          member.should have(1).error_on(:name)
        end

        it "#surname" do
          member = Fabricate.build(:member, surname: nil)

          member.should_not be_valid
          member.should have(1).error_on(:surname)
        end

        it "#email" do
          member = Fabricate.build(:member, email: nil)

          member.should_not be_valid
          member.should have(1).error_on(:email)
        end

        it "#about_you" do
          member = Fabricate.build(:member, about_you: nil)

          member.should_not be_valid
          member.should have(1).error_on(:about_you)
        end

      end
    end

    context "uniqueness" do
      it "#email" do
        Fabricate(:member, email: "sample@email.com")

        expect { Fabricate(:member, email: "sample@email.com") }.to raise_error
      end
    end

    context "properties" do
      let (:member) { Fabricate(:member) }

      it "#full_name" do
        member.full_name.should eq "#{member.name} #{member.surname}"
      end

      it "#avatar" do
        encrypted_email = Digest::MD5.hexdigest(member.email.strip.downcase)
        member.avatar.should eq "http://gravatar.com/avatar/#{encrypted_email}?s=100"
      end


      it "#attended_sessions" do
        member.session_invitations = 3.times.map { Fabricate(:attended_session_invitation) }
        member.session_invitations << Fabricate(:session_invitation)

        member.attended_sessions.count.should eq 3
      end

    end

    context "scopes" do
      before do
        3.times { Fabricate(:student) }
        6.times { Fabricate(:coach) }
        2.times { Fabricate(:member) }
        4.times { Fabricate(:admin) }
      end

      it "#students" do
        Member.students.count.should eq 3
      end

      it "#coaches" do
        Member.coaches.count.should eq 6
      end

      it "#admins" do
        Member.admins.count.should eq 4
      end
    end

  end
end
