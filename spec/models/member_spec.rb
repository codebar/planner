require 'spec_helper'

RSpec.describe Member, type: :model  do
  context 'mandatory attributes' do
    context 'validation' do
      it { is_expected.to validate_presence_of(:auth_services) }

      context 'logginable member' do
        let(:loginnable_member) { Fabricate.build(:member, can_log_in: true) }
        it { expect(loginnable_member).to validate_presence_of(:name) }
        it { expect(loginnable_member).to validate_presence_of(:surname) }
        it { expect(loginnable_member).to validate_presence_of(:email) }
        it { expect(loginnable_member).to validate_presence_of(:about_you) }
      end

      it { is_expected.to validate_length_of(:about_you).is_at_most(255) }
      it { is_expected.to validate_uniqueness_of(:email)}
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
    end
  end

  describe '.with_skill' do
    it 'returns members with the specified skill' do
      ruby_member = Fabricate(:coach, skill_list: 'ruby, rails')
      non_ruby_member = Fabricate(:coach, skill_list: 'html, jQuery')
      expect(Member.with_skill('ruby')).to eq [ruby_member]
    end
  end

  context 'scopes' do
    context '#attending_meeting' do
      it 'includes attending members' do
        invitation = Fabricate(:attending_meeting_invitation)

        expect(Member.attending_meeting(invitation.meeting)).to include(invitation.member)
      end

      it 'excludes banned attending members' do
        invitation = Fabricate(:banned_attending_meeting_invitation)

        expect(Member.attending_meeting(invitation.meeting)).to_not include(invitation.member)
      end
    end

    context '#in_group' do
      it 'includes members in group' do
        chapter = Fabricate(:chapter)
        group = Fabricate(:group, chapter: chapter, members: [Fabricate(:member)])

        expect(Member.in_group(chapter.groups)).to eq(group.members)
      end

      it 'excludes members outside group' do
        chapter = Fabricate(:chapter)
        other_chapter = Fabricate(:chapter)
        group = Fabricate(:group, chapter: other_chapter, members: [Fabricate(:member)])

        expect(Member.in_group(chapter.groups)).to_not eq(group.members)
      end

      it 'excludes banned members in group' do
        chapter = Fabricate(:chapter)
        group = Fabricate(:group, chapter: chapter, members: [Fabricate(:banned_member)])

        expect(Member.in_group(chapter.groups)).not_to eq(group.members)
      end
    end
  end
end
