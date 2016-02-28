require 'spec_helper'

describe Member do
  context "mandatory attributes" do
    context "validations for a logginable member" do
      context "presence" do
        it "#name" do
          member = Fabricate.build(:member, can_log_in: true, name: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:name)
        end

        it "#surname" do
          member = Fabricate.build(:member, can_log_in: true, surname: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:surname)
        end

        it "#email" do
          member = Fabricate.build(:member, can_log_in: true,  email: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:email)
        end

        it "#about_you" do
          member = Fabricate.build(:member, can_log_in: true, about_you: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:about_you)
        end

      end
    end

    context "uniqueness" do
      it "#email" do
        Fabricate(:member, email: "sample@email.com")

        expect { Fabricate(:member, email: "sample@email.com") }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context "properties" do
      let (:member) { Fabricate(:member) }

      it "#full_name" do
        expect(member.full_name).to eq("#{member.name} #{member.surname} (#{member.pronouns})")
      end

      it "#avatar" do
        encrypted_email = Digest::MD5.hexdigest(member.email.strip.downcase)
        expect(member.avatar).to eq("https://secure.gravatar.com/avatar/#{encrypted_email}?s=100")
      end

      it "#attended_sessions" do
        member.session_invitations = 3.times.map { Fabricate(:attended_session_invitation) }
        member.session_invitations << Fabricate(:session_invitation)

        expect(member.attended_sessions.count).to eq(3)
      end
    end
  end

  describe ".with_skill" do
    it "returns members with the specified skill" do
      ruby_member = Fabricate(:coach, skill_list: "ruby, rails")
      non_ruby_member = Fabricate(:coach, skill_list: "html, jQuery")
      expect(Member.with_skill('ruby')).to eq [ruby_member]
    end
  end

end
