require 'spec_helper'

describe Member do
  context 'mandatory attributes' do
    context 'validations for a logginable member' do
      context 'presence' do
        it '#name' do
          member = Fabricate.build(:member, can_log_in: true, name: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:name)
        end

        it '#surname' do
          member = Fabricate.build(:member, can_log_in: true, surname: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:surname)
        end

        it '#email' do
          member = Fabricate.build(:member, can_log_in: true, email: nil)

          expect(member).to_not be_valid
          expect(member).to have(1).error_on(:email)
        end

        context '#about_you' do
          it 'must be present' do
            member = Fabricate.build(:member, can_log_in: true, about_you: nil)

            expect(member).to_not be_valid
            expect(member).to have(1).error_on(:about_you)
          end

          it 'can be 255 characters in length' do
            text = 'a' * 255
            member = Fabricate.build(:member, can_log_in: true, about_you: text)

            expect(member).to be_valid
          end

          it 'cannot be longer than 255 characters' do
            text = 'a' * 256
            member = Fabricate.build(:member, can_log_in: true, about_you: text)

            expect(member).to_not be_valid
            expect(member).to have(1).error_on(:about_you)
          end
        end
      end
    end

    context 'uniqueness' do
      it '#email' do
        Fabricate(:member, email: 'sample@email.com')

        expect { Fabricate(:member, email: 'sample@email.com') }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'properties' do
      let (:member) { Fabricate(:member) }

      it '#full_name' do
        expect(member.full_name).to eq("#{member.name} #{member.surname} (#{member.pronouns})")
      end

      it '#avatar' do
        encrypted_email = Digest::MD5.hexdigest(member.email.strip.downcase)
        expect(member.avatar).to eq("https://secure.gravatar.com/avatar/#{encrypted_email}?size=100&default=identicon")
      end

      it '#attended_workshops' do
        member.workshop_invitations = 3.times.map { Fabricate(:attended_workshop_invitation) }
        member.workshop_invitations << Fabricate(:workshop_invitation)

        expect(member.attended_workshops.count).to eq(3)
      end
    end
  end

  describe '.with_skill' do
    it 'returns members with the specified skill' do
      ruby_member = Fabricate(:coach, skill_list: 'ruby, rails')
      non_ruby_member = Fabricate(:coach, skill_list: 'html, jQuery')
      expect(Member.with_skill('ruby')).to eq [ruby_member]
    end
  end
end
